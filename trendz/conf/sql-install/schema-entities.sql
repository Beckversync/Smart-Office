CREATE TABLE IF NOT EXISTS business_entity (
    id          UUID NOT NULL CONSTRAINT business_entity_pkey PRIMARY KEY,
    description VARCHAR(255),
    hidden      BOOLEAN NOT NULL,
    name        VARCHAR(255),
    query       VARCHAR(100000),

    tenant_id   UUID
);

CREATE TABLE IF NOT EXISTS business_entity_field (
    id                  UUID NOT NULL CONSTRAINT business_entity_field_pkey PRIMARY KEY,
    description         VARCHAR(255),
    hidden              BOOLEAN NOT NULL,
    name                VARCHAR(255),
    query               VARCHAR(100000),
    type                VARCHAR(255),
    calc_function       VARCHAR(100000),

    sql_id_key          BOOLEAN NOT NULL,
    sql_ts_key          BOOLEAN NOT NULL,

    business_entity_id  UUID REFERENCES business_entity(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS relation (
    business_entity_id  UUID NOT NULL REFERENCES business_entity(id) ON DELETE CASCADE,
    name                VARCHAR(255) NOT NULL,
    related_entity_id   UUID NOT NULL REFERENCES business_entity(id) ON DELETE CASCADE,
    direction           VARCHAR(255) NOT NULL,
    enabled             BOOLEAN NOT NULL,
    query               VARCHAR(100000),

    PRIMARY KEY (business_entity_id, name, related_entity_id, direction)
);



CREATE TABLE IF NOT EXISTS view_config (
    id                      UUID NOT NULL CONSTRAINT view_config_pkey PRIMARY KEY,
    config_definition       VARCHAR(100000),
    created_at              BIGINT,
    date_picker_config      VARCHAR(100000),
    name                    VARCHAR(255),
    runtime_filters         VARCHAR(100000),
    settings                VARCHAR(100000),
    tz_name                 VARCHAR(255),
    updated_at              BIGINT,
    view_type               VARCHAR(255),

    enable_report_cache                 BOOLEAN,
    enable_persisted_cache              BOOLEAN,
    cache_time_unit                     VARCHAR(50),
    auto_refresh_cache                  BOOLEAN,
    task_id                             UUID,
    refresh_frequency_time_unit         VARCHAR(50),
    refresh_frequency_time_unit_count   INTEGER,

    enable_calculated_telemetry_saving                      BOOLEAN NOT NULL DEFAULT false,
    calculated_telemetry_saving_task_id                     UUID,
    calculated_telemetry_saving_execution_time_unit         VARCHAR(255),
    calculated_telemetry_saving_execution_time_unit_count   INTEGER,

    root_entity_id      UUID,
    row_click_entity_id UUID,
    tenant_id           UUID NOT NULL,
    customer_id         UUID NOT NULL,
    collection_id       UUID NOT NULL,
    is_favorite         BOOLEAN NOT NULL,
    parent_path         VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS anomaly (
    id          UUID NOT NULL CONSTRAINT anomaly_pkey PRIMARY KEY,
    item_id     UUID,
    item_name   VARCHAR(255),
    start_ts    BIGINT,
    end_ts      BIGINT,
    cluster_id  BIGINT,
    score       DOUBLE PRECISION,
    score_index INTEGER,
    model_id    UUID
);

CREATE TABLE IF NOT EXISTS scored_point_anomaly (
    t           BIGINT,
    s           DOUBLE PRECISION,
    anomaly_id  UUID
);

CREATE TABLE IF NOT EXISTS ml_properties (
    id          UUID NOT NULL CONSTRAINT ml_properties_pkey PRIMARY KEY,
    json_value  varchar(10000000)
);

CREATE TABLE IF NOT EXISTS dataset_config (
    id                      UUID NOT NULL CONSTRAINT dataset_config_pkey PRIMARY KEY,
    max_points_count        INTEGER,
    start_ts                BIGINT,
    end_ts                  BIGINT,
    business_entity_id      UUID,
    business_entity_type    varchar(32),
    tz_name                 varchar(32)
);

CREATE TABLE IF NOT EXISTS cluster_model (
    id                  UUID NOT NULL CONSTRAINT cluster_model_pkey PRIMARY KEY,
    tenant_id           UUID,
    customer_id         UUID,
    create_ts           BIGINT,
    name                VARCHAR(255),
    status              VARCHAR(50),
    type                VARCHAR(50),
    properties_id       UUID REFERENCES ml_properties(id),
    dataset_config_id   UUID REFERENCES dataset_config(id),
    autodiscover_job_id UUID,
    autodiscover_enabled BOOLEAN default false,
    unit                VARCHAR(50),
    unit_count          INTEGER default 0
);

CREATE TABLE IF NOT EXISTS view_field (
    id                                  UUID NOT NULL CONSTRAINT view_field_pkey PRIMARY KEY,
    aggregation_type                    VARCHAR(255),
    use_delta                           BOOLEAN NOT NULL,
    color_config                        VARCHAR(100000),
    condition_field_ids                 VARCHAR(100000),
    date_grouping                       VARCHAR(100000),
    enable_runtime_filter               BOOLEAN NOT NULL,
    field_definition                    VARCHAR(255),
    hidden                              BOOLEAN NOT NULL,
    skip_render                         BOOLEAN NOT NULL,
    include_historical_data             BOOLEAN NOT NULL,
    field_label                         VARCHAR(255),
    local_time_range                    VARCHAR(100000),
    missed_relation_field               BOOLEAN NOT NULL,
    batch_calculation                   BOOLEAN NOT NULL,
    calc_function                       VARCHAR(100000),
    local_calculation                   BOOLEAN NOT NULL,
    from_template_entity_field          BOOLEAN NOT NULL,
    calculated_field                    BOOLEAN NOT NULL,
    state_condition                     VARCHAR(100000),
    state_field                         BOOLEAN NOT NULL,
    state_property                      VARCHAR(32),
    parsed_condition                    VARCHAR(100000),
    parsed_function                     VARCHAR(100000),
    is_anomaly_field                    BOOLEAN,
    anomaly_model_id                    UUID,
    is_prediction_model_field           BOOLEAN,
    prediction_model_id                 UUID,
    prediction_model_orig_entity_field_id UUID,
    is_set_prediction_period            BOOLEAN NOT NULL,
    prediction_period_unit              VARCHAR(32) NOT NULL,
    prediction_period_unit_count        INTEGER NOT NULL,
    selected_anomaly_field              VARCHAR(255),
    for_state_condition                 BOOLEAN NOT NULL,
    is_alarm_field                      BOOLEAN NOT NULL,
    selected_alarm_field                VARCHAR(255),
    script_language                     VARCHAR(30),
    fill_gap_enable                     BOOLEAN NOT NULL,
    fill_gap_time_unit                  VARCHAR(255),
    fill_gap_strategy                   VARCHAR(255),
    prediction_enabled                  BOOLEAN NOT NULL,
    prediction_method                   VARCHAR(255),
    prediction_range_sec                INTEGER NOT NULL,
    custom_prediction_method            VARCHAR(5120),
    multivariable_prediction_field_ids  VARCHAR(512),
    scale_value                         BOOLEAN NOT NULL,
    separate_axis                       BOOLEAN NOT NULL,
    separate_view_group                 BOOLEAN NOT NULL,
    seria_type                          VARCHAR(255),
    unit                                VARCHAR(255),
    virtual_date_field                  BOOLEAN NOT NULL,
    field_order                         INTEGER NOT NULL,
    visually_hidden_field               BOOLEAN NOT NULL,
    prediction_pre_aggregation_disabled BOOLEAN NOT NULL DEFAULT false,
    state_max_duration                  BIGINT NOT NULL DEFAULT 0,

    entity_field_id         UUID,
    business_entity_id      UUID,
    view_config_id          UUID,
    dataset_config_id       UUID
);

CREATE TABLE IF NOT EXISTS runtime_filter_field (
    id                  UUID NOT NULL CONSTRAINT runtime_filter_field_pkey PRIMARY KEY,
    json_value          varchar(10000000),
    dataset_config_id   UUID REFERENCES dataset_config(id)
);

CREATE TABLE IF NOT EXISTS cluster_info (
    id                  UUID NOT NULL CONSTRAINT cluster_info_pkey PRIMARY KEY,
    cluster_id          BIGINT,
    segments_count      INTEGER,
    segments_percent    INTEGER,
    duration_ms         BIGINT,
    min_score           DOUBLE PRECISION,
    max_score           DOUBLE PRECISION,
    cluster_model_id    UUID REFERENCES cluster_model(id)
);

CREATE TABLE IF NOT EXISTS scored_point_centroid (
    t BIGINT,
    s DOUBLE PRECISION,
    cluster_info_id UUID
);

CREATE TABLE IF NOT EXISTS scored_point_histogram (
    t               BIGINT,
    s               DOUBLE PRECISION,
    cluster_info_id UUID
);

CREATE TABLE IF NOT EXISTS cluster_example (
    id              UUID NOT NULL CONSTRAINT cluster_example_pkey PRIMARY KEY,
    cluster_info_id UUID REFERENCES cluster_info(id)
);

CREATE TABLE IF NOT EXISTS scored_point_cluster (
    t                   BIGINT,
    s                   DOUBLE PRECISION,
    cluster_example_id  UUID
);


CREATE TABLE IF NOT EXISTS cached_telemetry (
    id                          UUID NOT NULL CONSTRAINT cached_telemetry_pkey PRIMARY KEY,
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
    latest_telemetry_point_ts   BIGINT,

    UNIQUE (item_id, start_ts, end_ts, field_aggregation, date_aggregation_type, business_entity_field_id, function)
);

CREATE TABLE IF NOT EXISTS cached_telemetry_point (
    ts                  BIGINT NOT NULL,
    cached_telemetry_id UUID NOT NULL,
    numeric_value       DOUBLE PRECISION,
    string_value        VARCHAR(255),
    boolean_value       BOOLEAN,

    PRIMARY KEY (ts, cached_telemetry_id)
);


CREATE TABLE IF NOT EXISTS trendz_system_property (
    property_key   VARCHAR(1000) NOT NULL CONSTRAINT trendz_system_properties_pkey PRIMARY KEY,
    property_value VARCHAR(1000)
);



CREATE TABLE IF NOT EXISTS licence_data (
    tenant_id   UUID NOT NULL CONSTRAINT licence_data_pkey PRIMARY KEY,
    content     VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS view_collection (
    id              UUID NOT NULL CONSTRAINT view_collection_pkey PRIMARY KEY,
    tenant_id       UUID NOT NULL,
    customer_id     UUID NOT NULL,
    parent_id       UUID NOT NULL,
    collection_name VARCHAR(255) NOT NULL,
    creation_ts     BIGINT NOT NULL,
    update_ts       BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS custom_view_settings (
    domain                  VARCHAR(128) NOT NULL CONSTRAINT custom_view_settings_pkey PRIMARY KEY,
    palette_selection       VARCHAR(32),
    palette_trendz          VARCHAR(512),
    palette_tb              VARCHAR(512),
    url                     VARCHAR(128),
    tab_name                VARCHAR(128),
    logo_base64             VARCHAR(1500000),
    dark_mode               BOOLEAN NOT NULL,
    help_mode_enabled       BOOLEAN NOT NULL,
    thingsboard_redirect_url VARCHAR(512)
);

CREATE TABLE IF NOT EXISTS domain_tenant_pair (
    domain      VARCHAR(1024) NOT NULL,
    tenant_id   UUID NOT NULL,

    PRIMARY KEY (tenant_id, domain)
);


CREATE TABLE IF NOT EXISTS custom_prediction_model (
    id          UUID NOT NULL CONSTRAINT custom_prediction_model_pkey PRIMARY KEY,
    model_name  VARCHAR(32) NOT NULL,
    content     VARCHAR(5120) NOT NULL
);



CREATE TABLE IF NOT EXISTS datasource (
    id              UUID NOT NULL CONSTRAINT datasource_pkey PRIMARY KEY,
    tenant_id       UUID  NOT NULL,
    url             VARCHAR(255),
    login           VARCHAR(255),
    pass            VARCHAR(255)
);



CREATE TABLE IF NOT EXISTS calculation_field (
    id                              UUID NOT NULL CONSTRAINT calculation_field_pkey PRIMARY KEY,
    tenant_id                       UUID NOT NULL,
    customer_id                     UUID NOT NULL,
    enabled                         BOOLEAN NOT NULL,
    name                            VARCHAR(255) NOT NULL,
    creation_time                   BIGINT,
    update_time                     BIGINT,
    business_entity_id              UUID NOT NULL,
    associated_entity_field_id      UUID NOT NULL,
    language                        VARCHAR(32) NOT NULL,
    calculation_field_type          VARCHAR(32) NOT NULL,
    return_data_type                VARCHAR(32) NOT NULL,
    grouping_interval               VARCHAR(32) NOT NULL,
    field_aggregation               VARCHAR(32) NOT NULL,
    fill_gap_enable                 BOOLEAN NOT NULL,
    fill_gap_time_unit              VARCHAR(32),
    fill_gap_strategy               VARCHAR(32),
    tb_telemetry_key                VARCHAR(64) NOT NULL,
    script                          VARCHAR(51200) NOT NULL,
    time_range_strategy             VARCHAR(5120) NOT NULL,
    json_fixed_strategy_date_picker VARCHAR(5120),
    manual_dataset_id               UUID NOT NULL,

    UNIQUE (tenant_id, name)
);

CREATE TABLE IF NOT EXISTS manual_dataset (
    id              UUID NOT NULL CONSTRAINT manual_dataset_pkey PRIMARY KEY,
    data            VARCHAR(10240) NOT NULL
);

CREATE TABLE IF NOT EXISTS calculation_field_task_data (
    calculation_field_id                UUID NOT NULL CONSTRAINT calculation_field_task_data_pkey PRIMARY KEY,
    enabled                             BOOLEAN,
    tz_name                             VARCHAR(32),
    json_item_name_set                  TEXT,
    json_item_set                       TEXT,
    json_reprocess_date_picker_config   TEXT,
    refresh_time_unit                   VARCHAR(32),
    refresh_time_unit_count             INTEGER,
    refresh_time_unit_truncated         BOOLEAN
);


CREATE TABLE IF NOT EXISTS trendz_task (
    id                              UUID NOT NULL CONSTRAINT trendz_task_pkey PRIMARY KEY,
    tenant_id                       UUID NOT NULL,
    customer_id                     UUID NOT NULL,
    user_id                         UUID NOT NULL,
    created_ts                      BIGINT NOT NULL,
    updated_ts                      BIGINT NOT NULL,
    name                            VARCHAR(256) NOT NULL,
    enabled                         BOOLEAN NOT NULL,
    reference_type                  VARCHAR(128) NOT NULL,
    reference_key                   VARCHAR(128) NOT NULL,
    job_type                        VARCHAR(128) NOT NULL,
    json_job                        TEXT NOT NULL,
    schedule_type                   VARCHAR(128) NOT NULL,
    schedule_period_ts              BIGINT NOT NULL,
    schedule_planned_ts             BIGINT NOT NULL,
    schedule_scheduling_unit        VARCHAR(128) NOT NULL,
    schedule_scheduling_unit_count  INTEGER NOT NULL,
    schedule_scheduling_time_zone   VARCHAR(128) NOT NULL,
    ttl_enabled                     BOOLEAN NOT NULL,
    ttl_duration                    BIGINT NOT NULL,
    store_execution_enabled         BOOLEAN NOT NULL,
    store_execution_count           INTEGER NOT NULL,
    json_configs                    TEXT NOT NULL,

    UNIQUE (reference_type, reference_key)
);

CREATE TABLE IF NOT EXISTS trendz_task_execution_request (
    task_id                 UUID NOT NULL REFERENCES trendz_task(id) ON DELETE CASCADE,
    execution_id            UUID NOT NULL,
    tenant_id               UUID NOT NULL,
    customer_id             UUID NOT NULL,
    user_id                 UUID NOT NULL,
    scheduled               BOOLEAN NOT NULL,
    job_type                VARCHAR(128) NOT NULL,
    json_job                TEXT NOT NULL,
    created_ts              BIGINT NOT NULL,
    state                   VARCHAR(16) NOT NULL,

    PRIMARY KEY (task_id, execution_id)
);

CREATE TABLE IF NOT EXISTS trendz_task_execution (
    id                      UUID NOT NULL CONSTRAINT trendz_task_execution_pkey PRIMARY KEY,
    task_id                 UUID NOT NULL REFERENCES trendz_task(id) ON DELETE CASCADE,
    tenant_id               UUID NOT NULL,
    customer_id             UUID NOT NULL,
    user_id                 UUID NOT NULL,
    status                  VARCHAR(128) NOT NULL,
    created_ts              BIGINT NOT NULL,
    start_ts                BIGINT NOT NULL,
    finish_ts               BIGINT NOT NULL,
    duration                BIGINT NOT NULL,
    json_progress_content   TEXT NOT NULL,
    job_type                VARCHAR(128) NOT NULL,
    json_job                TEXT NOT NULL,
    json_result             TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS trendz_task_execution_progress_step (
    id                UUID NOT NULL CONSTRAINT trendz_task_execution_progress_step_pkey PRIMARY KEY,
    execution_id      UUID NOT NULL REFERENCES trendz_task_execution(id) ON DELETE CASCADE,
    parent_step_id    UUID REFERENCES trendz_task_execution_progress_step(id) ON DELETE CASCADE,
    name              VARCHAR(256) NOT NULL,
    start_ts          BIGINT NOT NULL,
    finish_ts         BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS trendz_task_scheduling_state_record (
    task_id             UUID NOT NULL CONSTRAINT trendz_task_state_record_pkey PRIMARY KEY,
    state               VARCHAR(16) NOT NULL,
    last_finish_ts      BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS trendz_task_execution_state_record (
    execution_id        UUID NOT NULL CONSTRAINT trendz_task_execution_state_record_pkey PRIMARY KEY,
    state               VARCHAR(16) NOT NULL,
    last_update_ts      BIGINT NOT NULL,
    removed_task        BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS trendz_task_sequence (
    id                      UUID NOT NULL CONSTRAINT trendz_task_sequence_pkey PRIMARY KEY,
    tenant_id               UUID NOT NULL,
    customer_id             UUID NOT NULL,
    user_id                 UUID NOT NULL,
    created_ts              BIGINT NOT NULL,
    updated_ts              BIGINT NOT NULL,
    name                    VARCHAR(256) NOT NULL,
    enabled                 BOOLEAN NOT NULL,
    json_configs            VARCHAR(10240) NOT NULL
);

CREATE TABLE IF NOT EXISTS trendz_task_sequence_item (
    id                  UUID NOT NULL CONSTRAINT trendz_task_sequence_item_pkey PRIMARY KEY,
    sequence_id         UUID NOT NULL,
    reference_type      VARCHAR(128) NOT NULL,
    reference_key       VARCHAR(128) NOT NULL,
    order_number        INTEGER,
    execution_delay_ms  BIGINT,

    CONSTRAINT fk_sequence FOREIGN KEY (sequence_id) REFERENCES trendz_task_sequence (id) ON DELETE CASCADE,
    CONSTRAINT fk_task_reference FOREIGN KEY (reference_type, reference_key) REFERENCES trendz_task (reference_type, reference_key) ON DELETE CASCADE
);

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

CREATE or replace function is_cached_telemetry_timestamps_do_not_intersect (_business_entity_field_id UUID, _item_id UUID, _date_aggregation_type varchar(255), _end_ts BIGINT, _start_ts BIGINT, _function varchar)
RETURNS BOOLEAN
LANGUAGE PLPGSQL
as $$
declare

BEGIN
  RETURN
    NOT EXISTS(
      SELECT 1 FROM cached_telemetry ct
      WHERE ct.item_id = _item_id
      and (
            --	case for everything except old calc fields. "function" field holds FieldGapSettings
            (_business_entity_field_id is not null and ct.business_entity_field_id = _business_entity_field_id)
      	    OR  --	case for old calculation field
            (_business_entity_field_id IS NULL AND NOT starts_with(_function, 'null') and _function = ct."function"))
      AND ct.date_aggregation_type = _date_aggregation_type
      AND NOT (ct.end_ts < _start_ts or ct.start_ts > _end_ts));
end;
$$;

DO $$
BEGIN
        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conname = 'is_timestamps_do_not_intersect_constraint'
        ) THEN
        ALTER TABLE cached_telemetry
            ADD CONSTRAINT is_timestamps_do_not_intersect_constraint
                CHECK (is_cached_telemetry_timestamps_do_not_intersect(business_entity_field_id, item_id, date_aggregation_type, end_ts,  start_ts, 'function'));
        END IF;
END $$;


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
    business_entity_field_id    UUID NOT NULL,
    avoid_disabling             BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS prediction_model_task_data (
    prediction_model_id         UUID NOT NULL CONSTRAINT prediction_model_task_data_pkey PRIMARY KEY,
    item_set_json               TEXT,
    enabled                     BOOLEAN,
    enabled_partial_fit         BOOLEAN,
    refresh_time_unit           VARCHAR(32),
    refresh_time_unit_count     INTEGER,
    refresh_time_unit_truncated BOOLEAN
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

CREATE TABLE IF NOT EXISTS prediction_model_last_item_point (
    prediction_model_id UUID NOT NULL,
    item_id             UUID NOT NULL,
    ts                  BIGINT NOT NULL,

    PRIMARY KEY (prediction_model_id, item_id)
);

CREATE TABLE IF NOT EXISTS agent_ai (
    id                  UUID NOT NULL CONSTRAINT agent_ai_pkey PRIMARY KEY,
    agent_type          VARCHAR(255) NOT NULL,
    system_message      VARCHAR(65536) NOT NULL,
    version             INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS view_assistance_chat (
    id                  UUID NOT NULL CONSTRAINT view_assistance_chat_pkey PRIMARY KEY,
    tenant_id           UUID NOT NULL,
    customer_id         UUID,
    user_id             UUID,

    chat_summary        VARCHAR(255),
    available_topology  TEXT,
    reference_key       VARCHAR(255),

    created_ts          BIGINT NOT NULL,
    last_modified_ts    BIGINT NOT NULL,

    is_deleted          BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS view_assistance_chat_message (
    id                  UUID NOT NULL CONSTRAINT view_assistance_chat_message_pkey PRIMARY KEY,
    chat_id             UUID NOT NULL REFERENCES view_assistance_chat (id) ON DELETE CASCADE,
    user_question       VARCHAR(65536) NOT NULL,

    ai_answer           TEXT,
    ai_memory           TEXT,
    json_job_response   TEXT,


    last_modified_by    VARCHAR(255) NOT NULL,
    created_ts          BIGINT NOT NULL,
    last_modified_ts    BIGINT NOT NULL,
    version             BIGINT NOT NULL,

    is_deleted          BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS view_assistance_token_usage (
    id                  UUID NOT NULL CONSTRAINT view_assistance_token_usage_pkey PRIMARY KEY,
    tenant_id           UUID NOT NULL,
    input_token_used    BIGINT NOT NULL DEFAULT 0,
    output_token_used   BIGINT NOT NULL DEFAULT 0,
    model_name          VARCHAR(255),
    start_of_month_ts   BIGINT NOT NULL,

    is_system_model     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS view_assistance_model_config (
    id                  UUID NOT NULL CONSTRAINT view_assistance_model_config_pkey PRIMARY KEY,
    tenant_id           UUID NOT NULL,

    model_provider      VARCHAR(255) NOT NULL,
    model_name          VARCHAR(255),
    json_properties     VARCHAR(10240) NOT NULL
);

CREATE TABLE IF NOT EXISTS view_assistance_admin_config (
     id                  UUID NOT NULL CONSTRAINT view_assistance_admin_config_pkey PRIMARY KEY,
     tenant_id           UUID NOT NULL,
     use_system_model    BOOLEAN NOT NULL,

     main_model_config   UUID REFERENCES view_assistance_model_config (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS custom_prompt_metadata(
        id                  UUID NOT NULL CONSTRAINT custom_prompt_metadata_pkey PRIMARY KEY,

        prompt              TEXT,
        data                TEXT,
        response            TEXT,

        tenant_id           UUID NOT NULL,
        customer_id         UUID,
        user_id             UUID,

        duration            BIGINT NOT NULL,
        created_ts          BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS view_assistance_user_metadata(
        id                      UUID NOT NULL CONSTRAINT view_assistance_user_metadata_pkey PRIMARY KEY,

        tenant_id               UUID NOT NULL,
        customer_id             UUID,
        user_id                 UUID,

        is_documentation_send   BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS custom_prompt(
        id                              UUID NOT NULL CONSTRAINT custom_prompt_pkey PRIMARY KEY,

        name                            VARCHAR(256) NOT NULL,
        prompt                          TEXT,
        is_system                       BOOLEAN NOT NULL DEFAULT FALSE,

        tenant_id                       UUID,
        customer_id                     UUID,
        user_id                         UUID,

        created_ts                      BIGINT NOT NULL,
        last_modified_ts                BIGINT NOT NULL,

        is_deleted                      BOOLEAN NOT NULL DEFAULT FALSE
);
