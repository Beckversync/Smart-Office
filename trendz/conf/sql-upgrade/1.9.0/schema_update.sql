ALTER TABLE scheduled_task ADD COLUMN IF NOT EXISTS customer_id UUID;
ALTER TABLE scheduled_task ADD COLUMN IF NOT EXISTS user_id UUID;
CREATE INDEX IF NOT EXISTS scheduled_task_customer_id_idx ON scheduled_task (customer_id);
CREATE INDEX IF NOT EXISTS scheduled_task_user_id_idx     ON scheduled_task (user_id);

CREATE TABLE IF NOT EXISTS licence_data (
    tenant_id   UUID NOT NULL CONSTRAINT licence_data_pkey PRIMARY KEY,
    content     VARCHAR(100)
);

ALTER TABLE scheduled_task ADD COLUMN IF NOT EXISTS status VARCHAR(10) NOT NULL DEFAULT 'FREE';
ALTER TABLE scheduled_task ADD COLUMN IF NOT EXISTS last_update_time BIGINT NOT NULL DEFAULT 0;


ALTER TABLE view_field ADD COLUMN IF NOT EXISTS use_delta BOOLEAN NOT NULL DEFAULT false;
UPDATE view_field SET use_delta = true, aggregation_type = 'SUM' where aggregation_type = 'DELTA';

ALTER TABLE dataset_config ADD COLUMN IF NOT EXISTS tz_name VARCHAR(32) NOT NULL DEFAULT 'UTC';


