ALTER TABLE cluster_model ADD COLUMN IF NOT EXISTS autodiscover_job_id UUID;
ALTER TABLE cluster_model ADD COLUMN IF NOT EXISTS autodiscover_enabled BOOLEAN default false;
ALTER TABLE cluster_model ADD COLUMN IF NOT EXISTS unit VARCHAR(50);
ALTER TABLE cluster_model ADD COLUMN IF NOT EXISTS unit_count INTEGER default 0;
CREATE INDEX IF NOT EXISTS cluster_model_to_autodiscover_job_id_idx ON cluster_model (autodiscover_job_id);
