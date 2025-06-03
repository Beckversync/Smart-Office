DELETE
FROM business_entity_field
WHERE business_entity_id NOT IN (SELECT id FROM business_entity);

DELETE
FROM relation
WHERE business_entity_id NOT IN (SELECT id FROM business_entity);

DELETE
FROM relation
WHERE related_entity_id NOT IN (SELECT id FROM business_entity);

DO
$$
    DECLARE
        fk_name TEXT;
    BEGIN
        SELECT conname
        INTO fk_name
        FROM pg_constraint
        WHERE conrelid = 'business_entity_field'::regclass
          AND confrelid = 'business_entity'::regclass;

        IF fk_name IS NOT NULL THEN
            EXECUTE 'ALTER TABLE business_entity_field DROP CONSTRAINT ' || fk_name;
        END IF;

        ALTER TABLE business_entity_field
            ADD FOREIGN KEY (business_entity_id) REFERENCES business_entity (id) ON DELETE CASCADE;

    END
$$;

DO
$$
    BEGIN

        IF NOT EXISTS (SELECT 1
                       FROM pg_constraint
                       WHERE conrelid = 'relation'::regclass
                         AND confrelid = 'business_entity'::regclass
                         AND conkey = ARRAY(SELECT attnum
                                            FROM pg_attribute
                                            WHERE attrelid = conrelid AND attname = 'business_entity_id')) THEN
            ALTER TABLE relation
                ADD FOREIGN KEY (business_entity_id) REFERENCES business_entity (id) ON DELETE CASCADE;
        END IF;

        IF NOT EXISTS (SELECT 1
                       FROM pg_constraint
                       WHERE conrelid = 'relation'::regclass
                         AND confrelid = 'business_entity'::regclass
                         AND conkey = ARRAY(SELECT attnum
                                            FROM pg_attribute
                                            WHERE attrelid = conrelid AND attname = 'related_entity_id')) THEN
            ALTER TABLE relation
                ADD FOREIGN KEY (related_entity_id) REFERENCES business_entity (id) ON DELETE CASCADE;
        END IF;

    END
$$;



CREATE TABLE IF NOT EXISTS calculation_field (
    id                          UUID NOT NULL CONSTRAINT calculation_field_pkey PRIMARY KEY,
    tenant_id                   UUID NOT NULL,
    customer_id                 UUID NOT NULL,
    enabled                     BOOLEAN NOT NULL,
    name                        VARCHAR(255) NOT NULL,
    creation_time               BIGINT,
    update_time                 BIGINT,
    business_entity_id          UUID NOT NULL,
    associated_entity_field_id  UUID NOT NULL,
    language                    VARCHAR(32) NOT NULL,
    calculation_field_type      VARCHAR(32) NOT NULL,
    return_data_type            VARCHAR(32) NOT NULL,
    grouping_interval           VARCHAR(32) NOT NULL,
    field_aggregation           VARCHAR(32) NOT NULL,
    fill_gap_enable             BOOLEAN NOT NULL,
    fill_gap_time_unit          VARCHAR(32),
    fill_gap_strategy           VARCHAR(32),
    tb_telemetry_key            VARCHAR(64) NOT NULL,
    script                      VARCHAR(5120) NOT NULL,
    manual_dataset_id           UUID NOT NULL,

    UNIQUE (tenant_id, name)
);

CREATE INDEX IF NOT EXISTS calculation_field_enabled_idx                ON calculation_field (enabled);
CREATE INDEX IF NOT EXISTS calculation_field_name_idx                   ON calculation_field (name);
CREATE INDEX IF NOT EXISTS calculation_field_tenant_id_idx              ON calculation_field (tenant_id);
CREATE INDEX IF NOT EXISTS calculation_field_customer_id_idx            ON calculation_field (customer_id);
CREATE INDEX IF NOT EXISTS calculation_field_business_entity_id_idx     ON calculation_field (business_entity_id);
CREATE INDEX IF NOT EXISTS calculation_field_language_idx               ON calculation_field (language);
CREATE INDEX IF NOT EXISTS calculation_field_calculation_field_type_idx ON calculation_field (calculation_field_type);


CREATE TABLE IF NOT EXISTS manual_dataset (
    id              UUID NOT NULL CONSTRAINT manual_dataset_pkey PRIMARY KEY,
    data            VARCHAR(10240) NOT NULL
);

CREATE TABLE IF NOT EXISTS calculation_field_task_data (
    calculation_field_id                UUID NOT NULL CONSTRAINT calculation_field_task_data_pkey PRIMARY KEY,
    tz_name                             VARCHAR(32),
    json_item_name_set                  TEXT,
    json_reprocess_date_picker_config   TEXT,
    refresh_time_unit                   VARCHAR(32),
    refresh_time_unit_count             INTEGER
);

ALTER TABLE cached_telemetry ADD COLUMN IF NOT EXISTS latest_telemetry_point_ts BIGINT;
UPDATE cached_telemetry SET latest_telemetry_point_ts = end_ts WHERE latest_telemetry_point_ts IS NULL;

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS prediction_pre_aggregation_disabled  BOOLEAN NOT null DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS trendz_task (
    id                  UUID NOT NULL CONSTRAINT trendz_task_pkey PRIMARY KEY,
    tenant_id           UUID NOT NULL,
    customer_id         UUID NOT NULL,
    user_id             UUID NOT NULL,
    created_ts          BIGINT NOT NULL,
    updated_ts          BIGINT NOT NULL,
    name                VARCHAR(256) NOT NULL,
    enabled             BOOLEAN NOT NULL,
    reference_type      VARCHAR(128) NOT NULL,
    reference_key       VARCHAR(128) NOT NULL,
    job_type            VARCHAR(128) NOT NULL,
    json_job            TEXT NOT NULL,
    schedule_type       VARCHAR(128) NOT NULL,
    schedule_period_ts  BIGINT NOT NULL,
    schedule_planned_ts BIGINT NOT NULL,
    ttl_enabled         BOOLEAN NOT NULL,
    ttl_duration        BIGINT NOT NULL,
    json_configs        TEXT NOT NULL,

    UNIQUE (reference_type, reference_key)
);

CREATE TABLE IF NOT EXISTS trendz_task_execution (
    id                UUID NOT NULL CONSTRAINT trendz_task_execution_pkey PRIMARY KEY,
    task_id           UUID NOT NULL REFERENCES trendz_task(id) ON DELETE CASCADE,
    tenant_id         UUID NOT NULL,
    customer_id       UUID NOT NULL,
    user_id           UUID NOT NULL,
    status            VARCHAR(128) NOT NULL,
    created_ts        BIGINT NOT NULL,
    start_ts          BIGINT NOT NULL,
    finish_ts         BIGINT NOT NULL,
    duration          BIGINT NOT NULL,
    expected_steps    INTEGER NOT NULL,
    job_type          VARCHAR(128) NOT NULL,
    json_job          TEXT NOT NULL,
    json_result       TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS trendz_task_execution_progress_step (
    id                UUID NOT NULL CONSTRAINT trendz_task_execution_progress_step_pkey PRIMARY KEY,
    execution_id      UUID NOT NULL REFERENCES trendz_task_execution(id) ON DELETE CASCADE,
    name              VARCHAR(256) NOT NULL,
    execution_order   INTEGER NOT NULL,
    start_ts          BIGINT NOT NULL,
    finish_ts         BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS trendz_task_scheduling_state_record (
    task_id             UUID NOT NULL CONSTRAINT trendz_task_state_record_pkey PRIMARY KEY,
    state               VARCHAR(16) NOT NULL,
    last_finish_ts      BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS trendz_task_execution_request (
    task_id         UUID NOT NULL REFERENCES trendz_task(id) ON DELETE CASCADE,
    execution_id    UUID NOT NULL,
    tenant_id       UUID NOT NULL,
    customer_id     UUID NOT NULL,
    user_id         UUID NOT NULL,
    scheduled       BOOLEAN NOT NULL,
    job_type        VARCHAR(128) NOT NULL,
    json_job        TEXT NOT NULL,
    created_ts      BIGINT NOT NULL,
    state           VARCHAR(16) NOT NULL,

    PRIMARY KEY (task_id, execution_id)
);

CREATE TABLE IF NOT EXISTS trendz_task_execution_state_record (
    execution_id        UUID NOT NULL CONSTRAINT trendz_task_execution_state_record_pkey PRIMARY KEY,
    state               VARCHAR(16) NOT NULL,
    last_update_ts      BIGINT NOT NULL,
    removed_task        BOOLEAN NOT NULL
);

CREATE INDEX IF NOT EXISTS trendz_task_user_combined_idx                       ON trendz_task (tenant_id, customer_id, user_id);
CREATE INDEX IF NOT EXISTS trendz_task_tenant_id_idx                           ON trendz_task (tenant_id);
CREATE INDEX IF NOT EXISTS trendz_task_customer_id_idx                         ON trendz_task (customer_id);
CREATE INDEX IF NOT EXISTS trendz_task_user_id_idx                             ON trendz_task (user_id);
CREATE INDEX IF NOT EXISTS trendz_task_created_ts_idx                          ON trendz_task (created_ts);
CREATE INDEX IF NOT EXISTS trendz_task_updated_ts_idx                          ON trendz_task (updated_ts);
CREATE INDEX IF NOT EXISTS trendz_task_name_idx                                ON trendz_task (name);
CREATE INDEX IF NOT EXISTS trendz_task_enabled_idx                             ON trendz_task (enabled);
CREATE INDEX IF NOT EXISTS trendz_task_reference_type_idx                      ON trendz_task (reference_type);
CREATE INDEX IF NOT EXISTS trendz_task_reference_key_idx                       ON trendz_task (reference_key);
CREATE INDEX IF NOT EXISTS trendz_task_job_type_idx                            ON trendz_task (job_type);
CREATE INDEX IF NOT EXISTS trendz_task_schedule_type_idx                       ON trendz_task (schedule_type);
CREATE INDEX IF NOT EXISTS trendz_task_schedule_period_ts_idx                  ON trendz_task (schedule_period_ts);
CREATE INDEX IF NOT EXISTS trendz_task_schedule_planned_ts_idx                 ON trendz_task (schedule_planned_ts);
CREATE INDEX IF NOT EXISTS trendz_task_ttl_enabled_idx                         ON trendz_task (ttl_enabled);
CREATE INDEX IF NOT EXISTS trendz_task_ttl_duration_idx                        ON trendz_task (ttl_duration);

CREATE INDEX IF NOT EXISTS trendz_task_execution_request_task_id_idx           ON trendz_task_execution_request (task_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_user_combined_idx     ON trendz_task_execution_request (tenant_id, customer_id, user_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_tenant_id_idx         ON trendz_task_execution_request (tenant_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_customer_id_idx       ON trendz_task_execution_request (customer_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_user_id_idx           ON trendz_task_execution_request (user_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_scheduled_idx         ON trendz_task_execution_request (scheduled);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_created_ts_idx        ON trendz_task_execution_request (created_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_state_ts_idx          ON trendz_task_execution_request (state);

CREATE INDEX IF NOT EXISTS trendz_task_execution_status_idx                    ON trendz_task_execution (status);
CREATE INDEX IF NOT EXISTS trendz_task_execution_created_ts_idx                ON trendz_task_execution (created_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_start_ts_idx                  ON trendz_task_execution (start_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_finish_ts_idx                 ON trendz_task_execution (finish_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_duration_ts_idx               ON trendz_task_execution (duration);
CREATE INDEX IF NOT EXISTS trendz_task_execution_job_type_idx                  ON trendz_task_execution (job_type);

CREATE INDEX IF NOT EXISTS trendz_task_execution_tenant_id_idx                 ON trendz_task_execution (tenant_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_customer_id_idx               ON trendz_task_execution (customer_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_user_id_idx                   ON trendz_task_execution (user_id);

CREATE INDEX IF NOT EXISTS trendz_task_scheduling_state_record_state_idx           ON trendz_task_scheduling_state_record (state);
CREATE INDEX IF NOT EXISTS trendz_task_scheduling_state_record_last_finish_ts_idx  ON trendz_task_scheduling_state_record (last_finish_ts);

CREATE INDEX IF NOT EXISTS trendz_task_execution_state_record_state_idx            ON trendz_task_execution_state_record (state);
CREATE INDEX IF NOT EXISTS trendz_task_execution_state_record_last_update_ts_idx   ON trendz_task_execution_state_record (last_update_ts);


ALTER TABLE cluster_model ADD COLUMN IF NOT EXISTS customer_id UUID NOT NULL DEFAULT '13814000-1dd2-11b2-8080-808080808080';
CREATE INDEX IF NOT EXISTS cluster_model_to_tenant_id_idx                   ON cluster_model (tenant_id);
CREATE INDEX IF NOT EXISTS cluster_model_to_customer_id_idx                 ON cluster_model (customer_id);

ALTER TABLE anomaly DROP COLUMN IF EXISTS task_id;
ALTER TABLE dataset_config DROP COLUMN IF EXISTS tenant_id;
ALTER TABLE dataset_config ADD COLUMN IF NOT EXISTS business_entity_type VARCHAR(32) NOT NULL DEFAULT 'DEVICE';

DROP TABLE IF EXISTS customization_data;
CREATE TABLE IF NOT EXISTS user_record (
    tenant_id           UUID NOT NULL,
    customer_id         UUID NOT NULL,
    user_id             UUID NOT NULL,
    username            VARCHAR(64) NOT NULL,
    visit_first_ts      BIGINT NOT NULL,
    visit_last_ts       BIGINT NOT NULL,
    valid               BOOLEAN NOT NULL,
    validation_last_ts  BIGINT NOT NULL,
    json_data           TEXT NOT NULL,

    PRIMARY KEY (tenant_id, customer_id, user_id)
);

CREATE TABLE IF NOT EXISTS latest_telemetry (
    calculation_field_id    UUID NOT NULL,
    item_id                 UUID NOT NULL,
    key                     VARCHAR(128) NOT NULL,
    value                   BIGINT NOT NULL,

    PRIMARY KEY (calculation_field_id, item_id, key)
);

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS local_calculation BOOLEAN NOT NULL DEFAULT TRUE;
DO
$$
    BEGIN
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_name = 'view_field' AND column_name = 'from_template_entity_field'
        ) THEN
            ALTER TABLE view_field ADD COLUMN from_template_entity_field BOOLEAN NOT NULL DEFAULT FALSE;
            UPDATE view_field SET from_template_entity_field = TRUE WHERE calculated_field = TRUE AND entity_field_id IS NOT NULL;
        END IF;
    END
$$;

CREATE INDEX IF NOT EXISTS business_entity_field_entity_id_idx              ON business_entity_field (business_entity_id);
CREATE INDEX IF NOT EXISTS relation_entity_id_idx                           ON relation (business_entity_id);
CREATE INDEX IF NOT EXISTS relation_related_entity_id_idx                   ON relation (related_entity_id);
CREATE INDEX IF NOT EXISTS view_config_is_favorite_idx                      ON view_config (is_favorite);
CREATE INDEX IF NOT EXISTS anomaly_cluster_id_idx                           ON anomaly (cluster_id);
CREATE INDEX IF NOT EXISTS cluster_model_properties_id_idx                  ON cluster_model (properties_id);
CREATE INDEX IF NOT EXISTS cluster_model_dataset_config_id_idx              ON cluster_model (dataset_config_id);
CREATE INDEX IF NOT EXISTS view_field_entity_field_id_idx                   ON view_field (entity_field_id);
CREATE INDEX IF NOT EXISTS view_field_business_entity_id_idx                ON view_field (business_entity_id);
CREATE INDEX IF NOT EXISTS runtime_filter_field_dataset_config_id_idx       ON runtime_filter_field (dataset_config_id);
CREATE INDEX IF NOT EXISTS cluster_info_cluster_id_idx                      ON cluster_info (cluster_id);
CREATE INDEX IF NOT EXISTS cached_telemetry_business_entity_id_idx          ON cached_telemetry (business_entity_id);
CREATE INDEX IF NOT EXISTS view_collection_collection_name_idx              ON view_collection (collection_name);
CREATE INDEX IF NOT EXISTS domain_tenant_pair_domain_idx                    ON domain_tenant_pair (domain);
CREATE INDEX IF NOT EXISTS domain_tenant_pair_tenant_id_idx                 ON domain_tenant_pair (tenant_id);
CREATE INDEX IF NOT EXISTS datasource_tenant_id_idx                         ON datasource (tenant_id);
CREATE INDEX IF NOT EXISTS calculation_field_associated_entity_field_id_idx ON calculation_field (associated_entity_field_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_job_type_idx       ON trendz_task_execution_request (job_type);
CREATE INDEX IF NOT EXISTS trendz_task_execution_task_id_idx                ON trendz_task_execution (task_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_user_combined_idx          ON trendz_task_execution (tenant_id, customer_id, user_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_progress_step_execution_id_idx    ON trendz_task_execution_progress_step (execution_id);
CREATE INDEX IF NOT EXISTS user_record_tenant_id_idx                            ON user_record (tenant_id);
CREATE INDEX IF NOT EXISTS user_record_customer_id_idx                          ON user_record (customer_id);
CREATE INDEX IF NOT EXISTS user_record_user_id_idx                              ON user_record (user_id);
CREATE INDEX IF NOT EXISTS user_record_username_idx                             ON user_record (username);
CREATE INDEX IF NOT EXISTS latest_telemetry_calculation_field_id_idx            ON latest_telemetry (calculation_field_id);
CREATE INDEX IF NOT EXISTS latest_telemetry_item_id_idx                         ON latest_telemetry (item_id);
CREATE INDEX IF NOT EXISTS latest_telemetry_key_idx                             ON latest_telemetry (key);


ALTER TABLE custom_view_settings ADD COLUMN IF NOT EXISTS help_mode_enabled BOOLEAN DEFAULT TRUE;
ALTER TABLE custom_view_settings ADD COLUMN IF NOT EXISTS thingsboard_redirect_url VARCHAR(512) DEFAULT 'None';
