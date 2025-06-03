DROP TABLE IF EXISTS business_entity CASCADE;
DROP TABLE IF EXISTS view_config CASCADE;


CREATE TABLE IF NOT EXISTS business_entity (
    id          UUID NOT NULL CONSTRAINT business_entity_pkey PRIMARY KEY,
    description VARCHAR(255),
    hidden      BOOLEAN NOT NULL,
    name        VARCHAR(255),
    query       VARCHAR(100000),

    tenant_id   UUID
);

CREATE TABLE IF NOT EXISTS view_config (
    id                  UUID NOT NULL CONSTRAINT view_config_pkey PRIMARY KEY,
    config_definition   VARCHAR(100000),
    created_at          BIGINT,
    date_picker_config  VARCHAR(100000),
    end_ts              BIGINT,
    name                VARCHAR(255),
    runtime_filters     VARCHAR(100000),
    settings            VARCHAR(100000),
    start_ts            BIGINT,
    tz_name             VARCHAR(255),
    updated_at          BIGINT,
    view_type           VARCHAR(255),

    root_entity_id      UUID,
    row_click_entity_id UUID,
    tenant_id           UUID
);

CREATE TABLE IF NOT EXISTS business_entity_field (
    id                  UUID NOT NULL CONSTRAINT business_entity_field_pkey PRIMARY KEY,
    description         VARCHAR(255),
    hidden              BOOLEAN NOT NULL,
    name                VARCHAR(255),
    options             TEXT [],
    query               VARCHAR(100000),
    type                VARCHAR(255),

    business_entity_id  UUID REFERENCES business_entity(id)
);

CREATE TABLE IF NOT EXISTS relation (
    business_entity_id  UUID NOT NULL,
    name                VARCHAR(255) NOT NULL,
    related_entity_id   UUID NOT NULL,
    direction           VARCHAR(255) NOT NULL,
    enabled             BOOLEAN NOT NULL,
    query               VARCHAR(100000),
    PRIMARY KEY (business_entity_id, name, related_entity_id, direction)
);

CREATE TABLE IF NOT EXISTS anomaly (
    id UUID NOT NULL CONSTRAINT anomaly_pkey PRIMARY KEY,
    item_id UUID,
    item_name VARCHAR(255),
    start_ts BIGINT,
    end_ts BIGINT,
    cluster_id BIGINT,
    score DOUBLE PRECISION,
    score_index INTEGER,
    model_id UUID,
    task_id UUID
);

CREATE TABLE IF NOT EXISTS scored_point_anomaly (
    t BIGINT,
    s DOUBLE PRECISION,
    anomaly_id UUID
);

CREATE TABLE IF NOT EXISTS task_progress (
    id UUID NOT NULL CONSTRAINT task_progress_pkey PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS progress_step (
    id UUID NOT NULL CONSTRAINT progress_step_pkey PRIMARY KEY,
    step_order INTEGER,
    description VARCHAR(255),
    expected_operations BIGINT,
    finished_operations BIGINT,
    started BOOLEAN,
    completed BOOLEAN,
    duration_ms BIGINT,
    task_progress_id UUID REFERENCES task_progress(id)
);

CREATE TABLE IF NOT EXISTS task (
    id UUID NOT NULL CONSTRAINT task_pkey PRIMARY KEY,
    model_id UUID,
    type VARCHAR(50),
    status VARCHAR(50),
    created_at BIGINT,
    started_at BIGINT,
    completed_at BIGINT,
    complete_reason VARCHAR(1000),
    progress_id UUID REFERENCES task_progress(id)
);

CREATE TABLE IF NOT EXISTS ml_properties (
    id UUID NOT NULL CONSTRAINT ml_properties_pkey PRIMARY KEY,
    json_value varchar(10000000)
);

CREATE TABLE IF NOT EXISTS dataset_config (
    id UUID NOT NULL CONSTRAINT dataset_config_pkey PRIMARY KEY,
    max_points_count INTEGER,
    start_ts BIGINT,
    end_ts BIGINT,
    tenant_id UUID
);

CREATE TABLE IF NOT EXISTS cluster_model (
    id uuid NOT NULL CONSTRAINT cluster_model_pkey PRIMARY KEY,
    create_ts BIGINT,
    name VARCHAR(255),
    status VARCHAR(50),
    type VARCHAR(50),
    properties_id UUID REFERENCES ml_properties(id),
    dataset_config_id UUID REFERENCES dataset_config(id)
);

CREATE TABLE IF NOT EXISTS view_field (
    id                      UUID NOT NULL CONSTRAINT view_field_pkey PRIMARY KEY,
    aggregation_type        VARCHAR(255),
    batch_calculation       BOOLEAN NOT NULL,
    calc_function           VARCHAR(100000),
    calculated_field        BOOLEAN NOT NULL,
    color_config            VARCHAR(100000),
    condition_field_ids     VARCHAR(100000),
    date_grouping           VARCHAR(100000),
    enable_runtime_filter   BOOLEAN NOT NULL,
    field_definition        VARCHAR(255),
    for_state_condition     BOOLEAN NOT NULL,
    hidden                  BOOLEAN NOT NULL,
    include_historical_data BOOLEAN NOT NULL,
    field_label             VARCHAR(255),
    local_time_range        VARCHAR(100000),
    missed_relation_field   BOOLEAN NOT NULL,
    parsed_condition        VARCHAR(100000),
    parsed_function         VARCHAR(100000),
    prediction_enabled      BOOLEAN NOT NULL,
    prediction_method       VARCHAR(255),
    prediction_range_sec    INTEGER NOT NULL,
    scale_value             BOOLEAN NOT NULL,
    separate_axis           BOOLEAN NOT NULL,
    separate_view_group     BOOLEAN NOT NULL,
    seria_type              VARCHAR(255),
    state_condition         VARCHAR(100000),
    state_field             BOOLEAN NOT NULL,
    unit                    VARCHAR(255),
    virtual_date_field      BOOLEAN NOT NULL,
    field_order             INTEGER NOT NULL,

    entity_field_id         UUID,
    business_entity_id      UUID,
    view_config_id          UUID,
    dataset_config_id       UUID
);

CREATE TABLE IF NOT EXISTS runtime_filter_field (
    id UUID NOT NULL CONSTRAINT runtime_filter_field_pkey PRIMARY KEY,
    json_value varchar(10000000),
    dataset_config_id UUID REFERENCES dataset_config(id)
);

CREATE TABLE IF NOT EXISTS cluster_info (
    id UUID NOT NULL CONSTRAINT cluster_info_pkey PRIMARY KEY,
    cluster_id BIGINT,
    segments_count INTEGER,
    segments_percent INTEGER,
    duration_ms BIGINT,
    min_score DOUBLE PRECISION,
    max_score DOUBLE PRECISION,
    cluster_model_id UUID REFERENCES cluster_model(id)
);

CREATE TABLE IF NOT EXISTS scored_point_centroid (
    t BIGINT,
    s DOUBLE PRECISION,
    cluster_info_id UUID
);

CREATE TABLE IF NOT EXISTS scored_point_histogram (
    t BIGINT,
    s DOUBLE PRECISION,
    cluster_info_id UUID
);

CREATE TABLE IF NOT EXISTS cluster_example (
    id UUID NOT NULL CONSTRAINT cluster_example_pkey PRIMARY KEY,
    cluster_info_id UUID REFERENCES cluster_info(id)
);

CREATE TABLE IF NOT EXISTS scored_point_cluster (
    t BIGINT,
    s DOUBLE PRECISION,
    cluster_example_id UUID
);


CREATE INDEX IF NOT EXISTS point_to_cluster_example_id_idx ON scored_point_cluster (cluster_example_id);
CREATE INDEX IF NOT EXISTS histogram_to_cluster_info_id_idx ON scored_point_histogram (cluster_info_id);
CREATE INDEX IF NOT EXISTS centroid_to_cluster_info_id_idx ON scored_point_centroid (cluster_info_id);
CREATE INDEX IF NOT EXISTS point_to_anomaly_id_idx ON scored_point_anomaly (anomaly_id);

CREATE INDEX IF NOT EXISTS cluster_ex_to_info_idx ON cluster_example (cluster_info_id);
CREATE INDEX IF NOT EXISTS cluster_info_to_model_idx ON cluster_info (cluster_model_id);

CREATE INDEX IF NOT EXISTS anomaly_item_id_idx ON anomaly (item_id);
CREATE INDEX IF NOT EXISTS anomaly_model_id_idx ON anomaly (model_id);
CREATE INDEX IF NOT EXISTS anomaly_task_id_idx ON anomaly (task_id);
CREATE INDEX IF NOT EXISTS anomaly_start_ts_idx ON anomaly (start_ts);
CREATE INDEX IF NOT EXISTS anomaly_end_ts_idx ON anomaly (end_ts);
CREATE INDEX IF NOT EXISTS anomaly_score_idx ON anomaly (score);

CREATE INDEX IF NOT EXISTS business_entity_tenant_id_idx ON business_entity (tenant_id);
CREATE INDEX IF NOT EXISTS view_config_tenant_id_idx ON view_config (tenant_id);
CREATE INDEX IF NOT EXISTS view_field_to_view_config_idx ON view_field (view_config_id);
CREATE INDEX IF NOT EXISTS view_field_to_dataset_config_idx ON view_field (dataset_config_id);
