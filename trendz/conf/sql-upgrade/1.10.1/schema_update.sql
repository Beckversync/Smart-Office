CREATE TABLE IF NOT EXISTS custom_view_settings (
    domain            VARCHAR(128) NOT NULL CONSTRAINT custom_view_settings_pkey PRIMARY KEY,
    palette_selection VARCHAR(32),
    palette_trendz    VARCHAR(512),
    palette_tb        VARCHAR(512),
    url               VARCHAR(128),
    tab_name          VARCHAR(128),
    logo_base64       VARCHAR(1500000),
    dark_mode         BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS domain_tenant_pair (
    domain    VARCHAR(1024) NOT NULL,
    tenant_id UUID NOT NULL,

    PRIMARY KEY (tenant_id, domain)
);


ALTER TABLE view_field ADD COLUMN IF NOT EXISTS script_language VARCHAR(30);
DO
$$
    BEGIN
        IF EXISTS (
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'view_field'
              AND column_name = 'is_js_code'
        )
        THEN
            BEGIN
                UPDATE view_field
                SET script_language = 'JS'
                WHERE is_js_code = true;

                UPDATE view_field
                SET script_language = 'JAVA'
                WHERE is_js_code = false;
            END;
        END IF;
    END
$$;
ALTER TABLE view_field DROP COLUMN IF EXISTS is_js_code;

UPDATE view_field set prediction_method = 'LINEAR_REGRESSION' where prediction_method = 'LINER_REGRESSION';
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS custom_prediction_method VARCHAR(5120);

UPDATE view_field set script_language = 'JS' where script_language = 'JAVA';

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS multivariable_prediction_field_ids VARCHAR(512);

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS visually_hidden_field BOOLEAN NOT NULL DEFAULT false;


CREATE TABLE IF NOT EXISTS custom_prediction_model (
    id          UUID NOT NULL CONSTRAINT custom_prediction_model_pkey PRIMARY KEY,
    model_name  VARCHAR(32) NOT NULL,
    content     VARCHAR(5120) NOT NULL
);

CREATE INDEX IF NOT EXISTS custom_prediction_model_model_name_idx ON custom_prediction_model (model_name);

INSERT INTO custom_prediction_model (id, model_name, content)
VALUES ('13814000-1dd2-11b2-8080-808080808080', 'Prophet Template',
        '
        import pandas as pd
        import numpy as np
        from prophet import Prophet

        futureRegressors = []
        regressorsCount = len(historyRegressors)

        for i in range(0, regressorsCount):
            regressorInputX = input_x
            regressorOutputX = output_x
            regressorInputY = regressors[i]
            regressorOutputY = []

            df = pd.DataFrame()
            df[''ds''] = pd.to_datetime(regressorInputX, unit=''ms'')
            df[''y''] = regressorInputY

            model = Prophet()
            model.fit(df)

            future = pd.DataFrame()
            future[''ds''] = pd.to_datetime(regressorOutputX, unit=''ms'')

            forecast = model.predict(future)
            regressorOutputY = forecast[''yhat''].tolist()
            futureRegressors.append(regressorOutputY)


        df = pd.DataFrame()
        df[''ds''] = pd.to_datetime(input_x, unit=''ms'')
        df[''y''] = np.array(input_y)
        for i in range(0, regressorsCount):
            df[''regressor'' + str(i)] = np.array(regressors[i])

        model = Prophet()
        for i in range(0, regressorsCount):
            model.add_regressor(''regressor'' + str(i), standardize=False)
        model.fit(df)

        future = pd.DataFrame()
        future[''ds''] = pd.to_datetime(output_x, unit=''ms'')
        for i in range(0, regressorsCount):
            future[''regressor'' + str(i)] = np.array(futureRegressors[i])

        forecast = model.predict(future)
        output_y = forecast[''yhat''].tolist()
        print(f"result: {output_y}")
        return output_y
        ')
ON CONFLICT (id) DO UPDATE
    SET model_name = EXCLUDED.model_name,
        content = EXCLUDED.content;
