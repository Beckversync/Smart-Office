export function getAnalytics(widgetCtx, isDefault, prompt) {
    if(!isDefault && !prompt) {
        throw new Error('You should indicate prompt/promptId or use default prompt');
    }

    const ctx = widgetCtx;
    const $injector = ctx.$scope.$injector;
    const customDialog = $injector.get(ctx.servicesMap.get('customDialog'));
    const widgetService = $injector.get(ctx.servicesMap.get('entityService')).widgetService;
    const jwtToken = localStorage.getItem('jwt_token');
    const {delay, pipe, switchMap, of, map} = ctx.rxjs;
    const title = widgetCtx.widget.config.showTitle && widgetCtx.widget.config.title ? widgetCtx.widget.config.title : '';

    const loaderHTML = `
        <div *ngIf="title" mat-dialog-title>{{title}}</div>
        <div mat-dialog-content style="padding: 0 24px">
            <div *ngIf="!summaryContent" class="flex items-center justify-center">
                <mat-spinner [diameter]="40"></mat-spinner>
            </div>
            <div *ngIf="summaryContent">{{summaryContent}}</div>
        </div>
        <div mat-dialog-actions class="flex items-center justify-end">
            <button mat-raised-button color="primary" (click)="cancel()">Close</button>
        </div>`;

    const dialogConfig = {
        width: '600px',
        maxWidth: '90%'
    }

    customDialog.customDialog(loaderHTML, getAnalyticsController, null, dialogConfig).subscribe()

    function getAnalyticsController(instance) {
        const dataForExport = ctx.defaultSubscription.exportData();
        const summaryData = transformToCsv(dataForExport);
        instance.summaryContent = '';
        instance.title = title;
        instance.cancel = () => instance.dialogRef.close(null);

        getAnalyticsUrl(widgetService, ctx, function (url, error) {
            if (error || !url) {
                console.error('Analytics URL not found.', error);
                instance.dialogRef.close(null);
                return;
            }

            getSummary(ctx, isDefault, prompt, summaryData, jwtToken, url).pipe(delay(200)).subscribe({
                next: (execution) => {
                    fetchTask(ctx, execution, jwtToken, url).subscribe(res => {
                        instance.summaryContent = res || 'Summary wasn`t generated!';
                    });
                },
                error: (error) => {
                    console.error('Error fetching summary:', error);
                    instance.dialogRef.close(null);
                }
            })
        });
    }
}

function transformToCsv(data) {
    if (data && data.length) {
        const header = Object.keys(data[0]).join(';');
        const rows = data.map(obj => Object.values(obj).join(';')).join('\n');
        return `${header}\n${rows}`;
    }
    return '';
}

function getSummary(ctx, isDefault, prompt, summaryData, jwtToken, analyticsLink) {
    let summaryRequest = { data: summaryData };

    if (!isDefault && prompt) {
        summaryRequest = isValidUUID(prompt)
            ? { promptId: prompt, data: summaryData }
            : { prompt: prompt, data: summaryData };
    }

    return ctx.http.post(`${analyticsLink}/apiTrendz/agent/prompts/execute`, summaryRequest, {
        headers: {
            Jwt: jwtToken
        }
    });
}

function fetchTask(ctx, executionId, jwtToken, analyticsLink) {
    return pollExecution(ctx, executionId, jwtToken, analyticsLink).pipe(ctx.rxjs.switchMap(res => {
        if(res.success) {
            if(res.success.status !== 'FINISHED') {
                return fetchTask(ctx, executionId, jwtToken, analyticsLink);
            } else {
                return ctx.rxjs.of(res.success.jsonResult ? res.success.jsonResult.result : null);
            }
        } else if(res.canceled) {
            const errorMessage = buildErrorMessage(res.canceled);
            return ctx.rxjs.of(errorMessage);
        }
    }))
}

function pollExecution(ctx, executionId, jwtToken, analyticsLink) {
    return ctx.http.get(`${analyticsLink}/apiTrendz/task/execution/poll/${executionId}`, {
        headers: { Jwt: jwtToken }
    }).pipe(
        ctx.rxjs.delay(300),
        ctx.rxjs.switchMap(execution => {
            if(!execution) {
                return ctx.rxjs.of({canceled: 'Failed to execute task'});
            }

            if(execution.status === 'CREATED' || execution.status === 'FINISHED' || execution.status === 'RUNNING') {
                return ctx.rxjs.of({success: execution})
            }

            return ctx.rxjs.of({canceled: execution.jsonResult});
        }))
}

function getAnalyticsUrl(widgetService, ctx, callback) {
    widgetService.getWidgetBundles(ctx.pageLink(100, 0, 'analysis_results'), true).subscribe(
        (res) => {
            if (res && res.data && res.data.length) {
                const analyticsBundle = res.data.find(bundle => bundle.alias === 'trendz_bundle')
                if(analyticsBundle) {
                    const analyticsBundleId = analyticsBundle.id.id;
                    widgetService.exportBundleWidgetTypesDetails(analyticsBundleId, true).subscribe(
                        (widgets) => {
                            const analyticsWidget = widgets.find(wdg => wdg.fqn === 'trendz_bundle.trendz_view_latest');
                            if (analyticsWidget && analyticsWidget.descriptor && analyticsWidget.descriptor.resources.length) {
                                const libUrl = analyticsWidget.descriptor.resources[0].url;
                                const url = new URL(libUrl).origin;
                                callback(url, null);
                            } else {
                                callback(null, 'Analytics widget not found');
                            }
                        },
                        (error) => {
                            callback(null, error.message || error);
                        }
                    );
                } else {
                    callback(null, 'Analytics bundle not found');
                }
            } else {
                callback(null, 'Analytics bundle not found');
            }
        },
        (error) => {
            callback(null, error.message || error);
        }
    );
}

function isValidUUID(uuid) {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(uuid);
}

function buildErrorMessage(errRes) {
    try {
        let errorMessage = '';

        errRes.forEach((el, idx) => {
            if(el.message && isJsonString(el.message)) {
                errorMessage += errRes.length > idx + 1 ? JSON.parse(el.message).message + '\n' : JSON.parse(el.message).message;
            } else {
                let errMessage = el.message ? el.message : '';
                errorMessage += errRes.length > idx + 1 ? errMessage + '\n ' : errMessage;
            }
        })

        return errorMessage;
    } catch (e) {
        console.log(e);
        return 'Invalid response!'
    }
}

function isJsonString (str) {
    try {
        JSON.parse(str);
        return true;
    } catch {
        return false;
    }
}
