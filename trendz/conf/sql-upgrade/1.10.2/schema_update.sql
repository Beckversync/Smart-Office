CREATE TABLE IF NOT EXISTS datasource (
    id              UUID NOT NULL CONSTRAINT datasource_pkey PRIMARY KEY,
    tenant_id UUID  NOT NULL,
    url             VARCHAR(255),
    login           VARCHAR(255),
    pass            VARCHAR(255)
);

ALTER TABLE business_entity_field ADD COLUMN IF NOT EXISTS sql_id_key BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE business_entity_field ADD COLUMN IF NOT EXISTS sql_ts_key BOOLEAN NOT NULL DEFAULT false;