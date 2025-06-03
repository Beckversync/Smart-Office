ALTER TABLE view_config ADD COLUMN IF NOT EXISTS customer_id UUID default '13814000-1dd2-11b2-8080-808080808080';
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS collection_id UUID default '13814000-1dd2-11b2-8080-808080808080';
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS is_favorite BOOLEAN default false;
ALTER TABLE view_config ADD COLUMN IF NOT EXISTS parent_path VARCHAR(255);

CREATE INDEX IF NOT EXISTS view_config_customer_id_idx      ON view_config (customer_id);
CREATE INDEX IF NOT EXISTS view_config_collection_id_idx    ON view_config (collection_id);
CREATE INDEX IF NOT EXISTS view_config_favorite_idx         ON view_config (is_favorite);

CREATE INDEX IF NOT EXISTS view_config_name_idx             ON view_config (name);

CREATE TABLE IF NOT EXISTS view_collection (
    id              UUID NOT NULL CONSTRAINT view_collection_pkey PRIMARY KEY,
    tenant_id       UUID NOT NULL,
    customer_id     UUID NOT NULL,
    parent_id       UUID NOT NULL,
    collection_name VARCHAR(255) NOT NULL,
    creation_ts     BIGINT NOT NULL,
    update_ts       BIGINT NOT NULL
);

CREATE INDEX IF NOT EXISTS view_collection_tenant_id_idx    ON view_collection (tenant_id);
CREATE INDEX IF NOT EXISTS view_collection_customer_id_idx  ON view_collection (customer_id);
CREATE INDEX IF NOT EXISTS view_collection_parent_id_idx    ON view_collection (parent_id);
