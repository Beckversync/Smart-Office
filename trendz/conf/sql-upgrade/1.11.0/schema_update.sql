-- DROP TABLE IF EXISTS scheduled_task;
-- DROP TABLE IF EXISTS scheduled_job;
-- DROP TABLE IF EXISTS scheduled_task_history_record;
-- DROP TABLE IF EXISTS task;
-- DROP TABLE IF EXISTS task_progress;
-- ALTER TABLE view_config DROP COLUMN IF EXISTS task_id;
-- ALTER TABLE view_config DROP COLUMN IF EXISTS calculated_telemetry_saving_task_id;

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

truncate table cached_telemetry, cached_telemetry_point;

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


ALTER TABLE calculation_field ADD COLUMN IF NOT EXISTS time_range_strategy              VARCHAR(32)     NOT NULL DEFAULT 'DYNAMIC';
ALTER TABLE calculation_field ADD COLUMN IF NOT EXISTS json_fixed_strategy_date_picker  VARCHAR(100000);

ALTER TABLE trendz_task ADD COLUMN IF NOT EXISTS store_execution_enabled BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE trendz_task ADD COLUMN IF NOT EXISTS store_execution_count   INTEGER NOT NULL DEFAULT 100;
CREATE INDEX IF NOT EXISTS trendz_task_store_execution_enabled_idx       ON trendz_task (store_execution_enabled);
CREATE INDEX IF NOT EXISTS trendz_task_store_execution_count_idx         ON trendz_task (store_execution_count);

ALTER TABLE view_field ADD COLUMN IF NOT EXISTS state_max_duration BIGINT NOT NULL DEFAULT 0;
