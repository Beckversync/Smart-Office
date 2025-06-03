ALTER TABLE view_field ADD COLUMN IF NOT EXISTS fill_gap_enable    BOOLEAN;
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS fill_gap_time_unit VARCHAR(255);
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS fill_gap_strategy  VARCHAR(255);
UPDATE view_field SET fill_gap_enable = false;

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS is_js_code BOOLEAN NOT NULL DEFAULT false;
UPDATE view_field SET is_js_code = false WHERE calculated_field = false and state_field = false;
UPDATE view_field SET is_js_code = false WHERE state_field = true;
UPDATE view_field SET is_js_code = true WHERE calculated_field = true;

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS is_anomaly_field        BOOLEAN;
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS anomaly_model_id        UUID;
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS selected_anomaly_field  VARCHAR(255);
UPDATE view_field SET is_anomaly_field = false;

CREATE TABLE IF NOT EXISTS trendz_system_property (
    property_key   VARCHAR(1000) NOT NULL CONSTRAINT trendz_system_properties_pkey PRIMARY KEY,
    property_value VARCHAR(1000)
);


ALTER TABLE view_config ADD COLUMN IF NOT EXISTS enable_calculated_telemetry_saving BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS calculated_telemetry_saving_task_id UUID;
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS calculated_telemetry_saving_execution_time_unit VARCHAR(255);
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS calculated_telemetry_saving_execution_time_unit_count INTEGER NOT NULL DEFAULT 0;

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS is_alarm_field BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE view_field ADD COLUMN IF NOT EXISTS selected_alarm_field VARCHAR(255);

UPDATE view_config SET refresh_frequency_time_unit = 'SECOND' where refresh_frequency_time_unit = 'second';
UPDATE view_config SET refresh_frequency_time_unit = 'MINUTE' where refresh_frequency_time_unit = 'minute';
UPDATE view_config SET refresh_frequency_time_unit = 'HOUR' where refresh_frequency_time_unit = 'hour';
UPDATE view_config SET refresh_frequency_time_unit = 'DAY' where refresh_frequency_time_unit = 'day';
UPDATE view_config SET refresh_frequency_time_unit = 'WEEK' where refresh_frequency_time_unit = 'week';
UPDATE view_config SET refresh_frequency_time_unit = 'MONTH' where refresh_frequency_time_unit = 'month';
UPDATE view_config SET refresh_frequency_time_unit = 'QUARTER' where refresh_frequency_time_unit = 'quarter';
UPDATE view_config SET refresh_frequency_time_unit = 'YEAR' where refresh_frequency_time_unit = 'year';
