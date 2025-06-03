ALTER TABLE calculation_field_task_data ADD COLUMN IF NOT EXISTS json_item_set TEXT;
UPDATE calculation_field cf SET grouping_interval = 'hour' WHERE cf.grouping_interval = 'minute';

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS state_property VARCHAR(32);
UPDATE view_field SET state_property = 'DURATION' WHERE aggregation_type = 'DURATION';
UPDATE view_field SET state_property = 'DURATION_PERCENT' WHERE aggregation_type = 'DURATION_PERCENT';
UPDATE view_field SET aggregation_type = 'SUM' WHERE state_property = 'DURATION' OR state_property = 'DURATION_PERCENT';
UPDATE trendz_task SET json_job = '{"viewConfig":null}' WHERE job_type = 'VIEW_REPORT_BUILD';
DELETE from trendz_task_execution WHERE job_type = 'VIEW_REPORT_BUILD';


UPDATE business_entity_field bef
SET query = jsonb_set(bef.query::jsonb, '{queryType}', '"STATE"', false), type = 'NUMERIC'
WHERE bef.type = 'STATE';

UPDATE business_entity_field bef
SET query = jsonb_set(bef.query::jsonb, '{queryType}', '"CALCULATED"', false), type = 'NUMERIC'
WHERE bef.type = 'CALCULATED';

ALTER TABLE business_entity_field DROP COLUMN IF EXISTS options;

UPDATE calculation_field cf
SET return_data_type = 'NUMERIC'
WHERE cf.return_data_type = 'CALCULATED';


DELETE FROM trendz_task_execution tte
WHERE tte.task_id IN (
    SELECT tt.id
    FROM trendz_task tt
    WHERE tt.job_type = 'TEST_CALCULATION_FIELD'
);

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS is_prediction_model_field BOOLEAN DEFAULT FALSE;
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS prediction_model_id UUID;
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS prediction_model_orig_entity_field_id UUID;
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS is_set_prediction_period BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS prediction_period_unit VARCHAR(32) NOT NULL DEFAULT 'day';
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS prediction_period_unit_count INTEGER NOT NULL DEFAULT 1;

CREATE TABLE IF NOT EXISTS prediction_model (
    id                          UUID NOT NULL CONSTRAINT prediction_model_pkey PRIMARY KEY,
    tenant_id                   UUID NOT NULL,
    customer_id                 UUID NOT NULL,
    created_ts                  BIGINT NOT NULL,
    updated_ts                  BIGINT NOT NULL,
    name                        VARCHAR(256) NOT NULL,
    enabled                     BOOLEAN NOT NULL,
    partial_fit_enabled         BOOLEAN NOT NULL,
    status                      VARCHAR(32) NOT NULL,
    type                        VARCHAR(32) NOT NULL,
    associated_entity_field_id  UUID NOT NULL,
    tb_telemetry_key            VARCHAR(128) NOT NULL,
    model_parameters            TEXT NOT NULL,
    datasource_parameters       TEXT NOT NULL,
    method_parameters           TEXT NOT NULL,
    item_state_map              TEXT NOT NULL,
    trained_item_set            TEXT NOT NULL,
    business_entity_id          UUID NOT NULL,
    business_entity_field_id    UUID NOT NULL
);


CREATE INDEX IF NOT EXISTS prediction_model_user_combined_idx               ON prediction_model (tenant_id, customer_id);
CREATE INDEX IF NOT EXISTS prediction_model_tenant_id_idx                   ON prediction_model (tenant_id);
CREATE INDEX IF NOT EXISTS prediction_model_name_idx                        ON prediction_model (name);
CREATE INDEX IF NOT EXISTS prediction_model_created_ts_idx                  ON prediction_model (created_ts);
CREATE INDEX IF NOT EXISTS prediction_model_updated_ts_idx                  ON prediction_model (updated_ts);
CREATE INDEX IF NOT EXISTS prediction_model_type_idx                        ON prediction_model (type);
CREATE INDEX IF NOT EXISTS prediction_model_business_entity_idx             ON prediction_model (business_entity_id);
CREATE INDEX IF NOT EXISTS prediction_model_business_entity_field_idx       ON prediction_model (business_entity_field_id);


CREATE TABLE IF NOT EXISTS prediction_model_task_data (
    prediction_model_id         UUID NOT NULL CONSTRAINT prediction_model_task_data_pkey PRIMARY KEY,
    item_set_json               TEXT,
    enabled                     BOOLEAN,
    enabled_partial_fit         BOOLEAN,
    refresh_time_unit           VARCHAR(32),
    refresh_time_unit_count     INTEGER
);

CREATE TABLE IF NOT EXISTS segment_data (
    id                          UUID NOT NULL CONSTRAINT segment_data_pkey PRIMARY KEY,
    model_id                    UUID,
    item_id                     UUID,
    item_name                   VARCHAR(128),
    range_start_ts              BIGINT,
    range_end_ts                BIGINT,
    prehistorical_telemetry     TEXT,
    historical_telemetry        TEXT,
    additional_telemetries      TEXT,
    prediction_telemetry        TEXT
);
CREATE INDEX IF NOT EXISTS segment_data_model_id_idx                    ON segment_data (model_id);
CREATE INDEX IF NOT EXISTS segment_data_item_id_idx                     ON segment_data (item_id);
CREATE INDEX IF NOT EXISTS segment_data_range_start_ts_idx              ON segment_data (range_start_ts);
CREATE INDEX IF NOT EXISTS segment_data_range_end_ts_idx                ON segment_data (range_end_ts);

CREATE TABLE IF NOT EXISTS prediction_model_last_item_point (
    prediction_model_id UUID NOT NULL,
    item_id             UUID NOT NULL,
    ts                  BIGINT NOT NULL,

    PRIMARY KEY (prediction_model_id, item_id)
);
CREATE INDEX IF NOT EXISTS prediction_model_last_item_point_prediction_model_id_idx ON prediction_model_last_item_point (prediction_model_id);
