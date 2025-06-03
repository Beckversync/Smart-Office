CREATE TABLE IF NOT EXISTS customization_data (
    tenant_id   UUID NOT NULL CONSTRAINT customization_data_pkey PRIMARY KEY,
    json_data   VARCHAR(1024)
);

ALTER TABLE task ADD COLUMN IF NOT EXISTS json_result VARCHAR(1000000);

ALTER TABLE dataset_config ADD COLUMN IF NOT EXISTS business_entity_id UUID;
