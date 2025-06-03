CREATE INDEX IF NOT EXISTS business_entity_tenant_id_idx                    ON business_entity (tenant_id);

CREATE INDEX IF NOT EXISTS business_entity_field_business_entity_id_idx     ON business_entity_field (business_entity_id);

CREATE INDEX IF NOT EXISTS relation_business_entity_id_idx                  ON relation (business_entity_id);
CREATE INDEX IF NOT EXISTS relation_related_entity_id_idx                   ON relation (related_entity_id);

CREATE INDEX IF NOT EXISTS view_config_tenant_id_idx                        ON view_config (tenant_id);
CREATE INDEX IF NOT EXISTS view_config_customer_id_idx                      ON view_config (customer_id);
CREATE INDEX IF NOT EXISTS view_config_collection_id_idx                    ON view_config (collection_id);
CREATE INDEX IF NOT EXISTS view_config_name_idx                             ON view_config (name);
CREATE INDEX IF NOT EXISTS view_config_is_favorite_idx                      ON view_config (is_favorite);

CREATE INDEX IF NOT EXISTS anomaly_item_id_idx                              ON anomaly (item_id);
CREATE INDEX IF NOT EXISTS anomaly_start_ts_idx                             ON anomaly (start_ts);
CREATE INDEX IF NOT EXISTS anomaly_end_ts_idx                               ON anomaly (end_ts);
CREATE INDEX IF NOT EXISTS anomaly_score_idx                                ON anomaly (score);
CREATE INDEX IF NOT EXISTS anomaly_model_id_idx                             ON anomaly (model_id);
CREATE INDEX IF NOT EXISTS anomaly_cluster_id_idx                           ON anomaly (cluster_id);

CREATE INDEX IF NOT EXISTS scored_point_anomaly_anomaly_id_idx              ON scored_point_anomaly (anomaly_id);

CREATE INDEX IF NOT EXISTS dataset_config_business_entity_id_idx            ON dataset_config (business_entity_id);

CREATE INDEX IF NOT EXISTS cluster_model_tenant_id_idx                      ON cluster_model (tenant_id);
CREATE INDEX IF NOT EXISTS cluster_model_customer_id_idx                    ON cluster_model (customer_id);
CREATE INDEX IF NOT EXISTS cluster_model_properties_id_idx                  ON cluster_model (properties_id);
CREATE INDEX IF NOT EXISTS cluster_model_dataset_config_id_idx              ON cluster_model (dataset_config_id);
CREATE INDEX IF NOT EXISTS cluster_model_autodiscover_job_id_idx            ON cluster_model (autodiscover_job_id);

CREATE INDEX IF NOT EXISTS view_field_view_config_idx                       ON view_field (view_config_id);
CREATE INDEX IF NOT EXISTS view_field_dataset_config_idx                    ON view_field (dataset_config_id);
CREATE INDEX IF NOT EXISTS view_field_entity_field_id_idx                   ON view_field (entity_field_id);
CREATE INDEX IF NOT EXISTS view_field_business_entity_id_idx                ON view_field (business_entity_id);

CREATE INDEX IF NOT EXISTS runtime_filter_field_dataset_config_id_idx       ON runtime_filter_field (dataset_config_id);

CREATE INDEX IF NOT EXISTS cluster_info_cluster_id_idx                      ON cluster_info (cluster_id);
CREATE INDEX IF NOT EXISTS cluster_info_cluster_model_id_idx                ON cluster_info (cluster_model_id);

CREATE INDEX IF NOT EXISTS scored_point_centroid_cluster_info_id_idx        ON scored_point_centroid (cluster_info_id);

CREATE INDEX IF NOT EXISTS scored_point_histogram_cluster_info_id_idx       ON scored_point_histogram (cluster_info_id);

CREATE INDEX IF NOT EXISTS cluster_example_cluster_info_id_idx              ON cluster_example (cluster_info_id);

CREATE INDEX IF NOT EXISTS scored_point_cluster_cluster_example_id_idx      ON scored_point_cluster (cluster_example_id);

CREATE INDEX IF NOT EXISTS cached_telemetry_id_idx                          ON cached_telemetry (id);
CREATE INDEX IF NOT EXISTS cached_telemetry_item_id_idx                     ON cached_telemetry (item_id);
CREATE INDEX IF NOT EXISTS cached_telemetry_tenant_id_idx                   ON cached_telemetry (tenant_id);
CREATE INDEX IF NOT EXISTS cached_telemetry_end_ts_idx                      ON cached_telemetry (end_ts);
CREATE INDEX IF NOT EXISTS cached_telemetry_start_ts_idx                    ON cached_telemetry (start_ts);
CREATE INDEX IF NOT EXISTS cached_telemetry_field_aggregation_idx           ON cached_telemetry (field_aggregation);
CREATE INDEX IF NOT EXISTS cached_telemetry_date_aggregation_type_idx       ON cached_telemetry (date_aggregation_type);
CREATE INDEX IF NOT EXISTS cached_telemetry_business_entity_id_idx          ON cached_telemetry (business_entity_id);
CREATE INDEX IF NOT EXISTS cached_telemetry_business_entity_field_id_idx    ON cached_telemetry (business_entity_field_id);
CREATE INDEX IF NOT EXISTS cached_telemetry_function_idx                    ON cached_telemetry (function);

CREATE INDEX IF NOT EXISTS cached_telemetry_point_ts_idx                    ON cached_telemetry_point (ts);
CREATE INDEX IF NOT EXISTS cached_telemetry_point_cached_telemetry_id_idx   ON cached_telemetry_point (cached_telemetry_id);

CREATE INDEX IF NOT EXISTS view_collection_tenant_id_idx                    ON view_collection (tenant_id);
CREATE INDEX IF NOT EXISTS view_collection_customer_id_idx                  ON view_collection (customer_id);
CREATE INDEX IF NOT EXISTS view_collection_parent_id_idx                    ON view_collection (parent_id);
CREATE INDEX IF NOT EXISTS view_collection_collection_name_idx              ON view_collection (collection_name);

CREATE INDEX IF NOT EXISTS domain_tenant_pair_domain_idx                    ON domain_tenant_pair (domain);
CREATE INDEX IF NOT EXISTS domain_tenant_pair_tenant_id_idx                 ON domain_tenant_pair (tenant_id);

CREATE INDEX IF NOT EXISTS custom_prediction_model_model_name_idx           ON custom_prediction_model (model_name);

CREATE INDEX IF NOT EXISTS datasource_tenant_id_idx                         ON datasource (tenant_id);

CREATE INDEX IF NOT EXISTS calculation_field_tenant_id_idx                  ON calculation_field (tenant_id);
CREATE INDEX IF NOT EXISTS calculation_field_customer_id_idx                ON calculation_field (customer_id);
CREATE INDEX IF NOT EXISTS calculation_field_enabled_idx                    ON calculation_field (enabled);
CREATE INDEX IF NOT EXISTS calculation_field_name_idx                       ON calculation_field (name);
CREATE INDEX IF NOT EXISTS calculation_field_business_entity_id_idx         ON calculation_field (business_entity_id);
CREATE INDEX IF NOT EXISTS calculation_field_associated_entity_field_id_idx ON calculation_field (associated_entity_field_id);
CREATE INDEX IF NOT EXISTS calculation_field_language_idx                   ON calculation_field (language);
CREATE INDEX IF NOT EXISTS calculation_field_calculation_field_type_idx     ON calculation_field (calculation_field_type);

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
CREATE INDEX IF NOT EXISTS trendz_task_store_execution_enabled_idx             ON trendz_task (store_execution_enabled);
CREATE INDEX IF NOT EXISTS trendz_task_store_execution_count_idx               ON trendz_task (store_execution_count);

CREATE INDEX IF NOT EXISTS trendz_task_execution_request_task_id_idx           ON trendz_task_execution_request (task_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_user_combined_idx     ON trendz_task_execution_request (tenant_id, customer_id, user_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_tenant_id_idx         ON trendz_task_execution_request (tenant_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_customer_id_idx       ON trendz_task_execution_request (customer_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_user_id_idx           ON trendz_task_execution_request (user_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_scheduled_idx         ON trendz_task_execution_request (scheduled);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_job_type_idx          ON trendz_task_execution_request (job_type);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_created_ts_idx        ON trendz_task_execution_request (created_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_request_state_ts_idx          ON trendz_task_execution_request (state);

CREATE INDEX IF NOT EXISTS trendz_task_execution_task_id_idx                   ON trendz_task_execution (task_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_user_combined_idx             ON trendz_task_execution (tenant_id, customer_id, user_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_tenant_id_idx                 ON trendz_task_execution (tenant_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_customer_id_idx               ON trendz_task_execution (customer_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_user_id_idx                   ON trendz_task_execution (user_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_status_idx                    ON trendz_task_execution (status);
CREATE INDEX IF NOT EXISTS trendz_task_execution_created_ts_idx                ON trendz_task_execution (created_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_start_ts_idx                  ON trendz_task_execution (start_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_finish_ts_idx                 ON trendz_task_execution (finish_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_duration_ts_idx               ON trendz_task_execution (duration);
CREATE INDEX IF NOT EXISTS trendz_task_execution_job_type_idx                  ON trendz_task_execution (job_type);

CREATE INDEX IF NOT EXISTS trendz_task_execution_progress_step_execution_id_idx ON trendz_task_execution_progress_step (execution_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_parent_step_id_idx             ON trendz_task_execution_progress_step (parent_step_id);
CREATE INDEX IF NOT EXISTS trendz_task_execution_start_ts_idx                   ON trendz_task_execution_progress_step (start_ts);
CREATE INDEX IF NOT EXISTS trendz_task_execution_finish_ts_idx                  ON trendz_task_execution_progress_step (finish_ts);

CREATE INDEX IF NOT EXISTS trendz_task_scheduling_state_record_state_idx           ON trendz_task_scheduling_state_record (state);
CREATE INDEX IF NOT EXISTS trendz_task_scheduling_state_record_last_finish_ts_idx  ON trendz_task_scheduling_state_record (last_finish_ts);

CREATE INDEX IF NOT EXISTS trendz_task_execution_state_record_state_idx            ON trendz_task_execution_state_record (state);
CREATE INDEX IF NOT EXISTS trendz_task_execution_state_record_last_update_ts_idx   ON trendz_task_execution_state_record (last_update_ts);

CREATE INDEX IF NOT EXISTS trendz_task_sequence_tenant_id_idx               ON trendz_task_sequence (tenant_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_customer_id_idx             ON trendz_task_sequence (customer_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_user_id_idx                 ON trendz_task_sequence (user_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_user_combined_idx           ON trendz_task_sequence (tenant_id, customer_id, user_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_created_ts_idx              ON trendz_task_sequence (created_ts);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_updated_ts_idx              ON trendz_task_sequence (updated_ts);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_name_idx                    ON trendz_task_sequence (name);

CREATE INDEX IF NOT EXISTS trendz_task_sequence_item_sequence_id_idx    ON trendz_task_sequence_item (sequence_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_item_reference_idx      ON trendz_task_sequence_item (reference_type, reference_key);


CREATE INDEX IF NOT EXISTS user_record_tenant_id_idx                            ON user_record (tenant_id);
CREATE INDEX IF NOT EXISTS user_record_customer_id_idx                          ON user_record (customer_id);
CREATE INDEX IF NOT EXISTS user_record_user_id_idx                              ON user_record (user_id);
CREATE INDEX IF NOT EXISTS user_record_username_idx                             ON user_record (username);

CREATE INDEX IF NOT EXISTS latest_telemetry_calculation_field_id_idx            ON latest_telemetry (calculation_field_id);
CREATE INDEX IF NOT EXISTS latest_telemetry_item_id_idx                         ON latest_telemetry (item_id);
CREATE INDEX IF NOT EXISTS latest_telemetry_key_idx                             ON latest_telemetry (key);


CREATE INDEX IF NOT EXISTS prediction_model_user_combined_idx               ON prediction_model (tenant_id, customer_id);
CREATE INDEX IF NOT EXISTS prediction_model_tenant_id_idx                   ON prediction_model (tenant_id);
CREATE INDEX IF NOT EXISTS prediction_model_name_idx                        ON prediction_model (name);
CREATE INDEX IF NOT EXISTS prediction_model_created_ts_idx                  ON prediction_model (created_ts);
CREATE INDEX IF NOT EXISTS prediction_model_updated_ts_idx                  ON prediction_model (updated_ts);
CREATE INDEX IF NOT EXISTS prediction_model_type_idx                        ON prediction_model (type);
CREATE INDEX IF NOT EXISTS prediction_model_datasource_parameters_idx       ON prediction_model (datasource_parameters);
CREATE INDEX IF NOT EXISTS prediction_model_business_entity_idx             ON prediction_model (business_entity_id);
CREATE INDEX IF NOT EXISTS prediction_model_business_entity_field_idx       ON prediction_model (business_entity_field_id);

CREATE INDEX IF NOT EXISTS segment_data_model_id_idx                    ON segment_data (model_id);
CREATE INDEX IF NOT EXISTS segment_data_item_id_idx                     ON segment_data (item_id);
CREATE INDEX IF NOT EXISTS segment_data_range_start_ts_idx              ON segment_data (range_start_ts);
CREATE INDEX IF NOT EXISTS segment_data_range_end_ts_idx                ON segment_data (range_end_ts);

CREATE INDEX IF NOT EXISTS prediction_model_last_item_point_prediction_model_id_idx ON prediction_model_last_item_point (prediction_model_id);
