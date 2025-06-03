ALTER TABLE business_entity_field ADD COLUMN IF NOT EXISTS calc_function VARCHAR(100000);

ALTER TABLE view_config DROP COLUMN IF EXISTS start_ts;
ALTER TABLE view_config DROP COLUMN IF EXISTS end_ts;
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS enable_report_cache                BOOLEAN;
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS enable_persisted_cache             BOOLEAN;
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS cache_time_unit                    VARCHAR(50);
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS auto_refresh_cache                 BOOLEAN;
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS task_id                            UUID;
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS refresh_frequency_time_unit        VARCHAR(50);
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS refresh_frequency_time_unit_count  INTEGER;

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS skip_render BOOLEAN NOT NULL default FALSE;

CREATE INDEX IF NOT EXISTS view_config_task_id_idx ON view_config (task_id);


CREATE TABLE IF NOT EXISTS cached_telemetry (
    id                          UUID,
    item_id                     UUID,
    tenant_id                   UUID,
    upload_time                 BIGINT,
    calculated_field            BOOLEAN,
    state_field                 BOOLEAN,
    start_ts                    BIGINT,
    end_ts                      BIGINT,
    field_type                  VARCHAR(255),
    field_aggregation           VARCHAR(255),
    date_aggregation_type       VARCHAR(255),
    business_entity_id          UUID,
    business_entity_field_id    UUID,
    function                    VARCHAR(1000000),

    UNIQUE (item_id, start_ts, end_ts, field_aggregation, date_aggregation_type, business_entity_field_id, function)
);

CREATE TABLE IF NOT EXISTS cached_telemetry_point (
    ts                  BIGINT NOT NULL,
    cached_telemetry_id UUID NOT NULL,
    numeric_value       DOUBLE PRECISION,
    string_value        VARCHAR(255),
    boolean_value       BOOLEAN
);


CREATE INDEX IF NOT EXISTS cached_telemetry_id_idx                          ON cached_telemetry (id);
CREATE INDEX IF NOT EXISTS cached_telemetry_item_id_idx                     ON cached_telemetry (item_id);
CREATE INDEX IF NOT EXISTS cached_telemetry_tenant_id_idx                   ON cached_telemetry (tenant_id);
CREATE INDEX IF NOT EXISTS cached_telemetry_end_ts_idx                      ON cached_telemetry (end_ts);
CREATE INDEX IF NOT EXISTS cached_telemetry_start_ts_idx                    ON cached_telemetry (start_ts);
CREATE INDEX IF NOT EXISTS cached_telemetry_field_aggregation_idx           ON cached_telemetry (field_aggregation);
CREATE INDEX IF NOT EXISTS cached_telemetry_date_aggregation_type_idx       ON cached_telemetry (date_aggregation_type);
CREATE INDEX IF NOT EXISTS cached_telemetry_business_entity_field_id_idx    ON cached_telemetry (business_entity_field_id);
CREATE INDEX IF NOT EXISTS cached_telemetry_function_idx                    ON cached_telemetry (function);

CREATE INDEX IF NOT EXISTS cached_telemetry_point_ts_idx                    ON cached_telemetry_point (ts);
CREATE INDEX IF NOT EXISTS cached_telemetry_point_cached_telemetry_id_idx   ON cached_telemetry_point (cached_telemetry_id);


CREATE TABLE IF NOT EXISTS scheduled_task (
    id                  UUID CONSTRAINT scheduled_task_pkey PRIMARY KEY,
    tenant_id           UUID,
    enabled             BOOLEAN,
    initial_delay       BIGINT NOT NULL,
    regular_delay       BIGINT NOT NULL,
    delay_time_unit     VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS scheduled_job (
    id                  UUID CONSTRAINT scheduled_job_pkey PRIMARY KEY,
    task_id             UUID,
    json_data           VARCHAR(1000)
);

CREATE TABLE IF NOT EXISTS scheduled_task_history_record (
    id                  UUID CONSTRAINT scheduled_task_history_record_pkey PRIMARY KEY,
    scheduled_task_id   UUID,
    record_timestamp    BIGINT NOT NULL,
    duration            BIGINT NOT NULL,
    status              VARCHAR(20),
    failure_reason      VARCHAR(1000)
);

CREATE INDEX IF NOT EXISTS scheduled_task_tenant_id_idx                 ON scheduled_task (tenant_id);
CREATE INDEX IF NOT EXISTS scheduled_job_task_id_idx                    ON scheduled_job (task_id);
CREATE INDEX IF NOT EXISTS scheduled_task_history_scheduled_task_id_idx ON scheduled_task_history_record (scheduled_task_id);

ALTER TABLE cluster_model ADD COLUMN IF NOT EXISTS tenant_id UUID;
CREATE INDEX IF NOT EXISTS cluster_model_tenant_id_idx ON cluster_model (tenant_id);
