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

CREATE INDEX IF NOT EXISTS trendz_task_sequence_tenant_id_idx       ON trendz_task_sequence (tenant_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_customer_id_idx     ON trendz_task_sequence (customer_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_user_id_idx         ON trendz_task_sequence (user_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_user_combined_idx   ON trendz_task_sequence (tenant_id, customer_id, user_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_created_ts_idx      ON trendz_task_sequence (created_ts);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_updated_ts_idx      ON trendz_task_sequence (updated_ts);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_name_idx            ON trendz_task_sequence (name);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_enabled_idx         ON trendz_task_sequence (enabled);

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

CREATE INDEX IF NOT EXISTS trendz_task_sequence_item_sequence_id_idx    ON trendz_task_sequence_item (sequence_id);
CREATE INDEX IF NOT EXISTS trendz_task_sequence_item_reference_idx      ON trendz_task_sequence_item (reference_type, reference_key);

ALTER TABLE prediction_model ADD COLUMN IF NOT EXISTS avoid_disabling BOOLEAN default false;


ALTER TABLE trendz_task ADD COLUMN IF NOT EXISTS schedule_scheduling_unit VARCHAR(128) NOT NULL DEFAULT 'HOURS';
ALTER TABLE trendz_task ADD COLUMN IF NOT EXISTS schedule_scheduling_unit_count INTEGER NOT NULL DEFAULT 1;
ALTER TABLE trendz_task ADD COLUMN IF NOT EXISTS schedule_scheduling_time_zone VARCHAR(128) NOT NULL DEFAULT 'UTC';
ALTER TABLE calculation_field_task_data ADD COLUMN IF NOT EXISTS refresh_time_unit_truncated BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE prediction_model_task_data ADD COLUMN IF NOT EXISTS refresh_time_unit_truncated BOOLEAN NOT NULL DEFAULT FALSE;


ALTER TABLE view_assistance_chat_message
ADD COLUMN IF NOT EXISTS ai_answer TEXT;
ALTER TABLE view_assistance_chat_message
ADD COLUMN IF NOT EXISTS ai_memory TEXT;
ALTER TABLE view_assistance_token_usage
ALTER COLUMN model_name DROP NOT NULL;
ALTER TABLE view_assistance_model_config
ALTER COLUMN model_name DROP NOT NULL;

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

DELETE FROM agent_ai
WHERE agent_type = 'TOPOLOGY_EXPERT' OR agent_type = 'DATA_EXPERT' OR agent_type = 'SIMPLE_TABLE_VIEW_EXPERT';

INSERT INTO custom_prompt (id, name, prompt, is_system, tenant_id, customer_id, user_id, created_ts, last_modified_ts, is_deleted)
VALUES (
    'a21d5620-161c-11f0-9cd2-0242ac120002',
    'Trendz System Default Summary Prompt',
    '
### CEO Summary: How Are We Doing?

Based on the latest data, here''s a high-level overview of our current performance:

- **Key Performance Trends**: Highlight the overall trajectory of performance, focusing on notable gains or areas for improvement.
- **Customer Satisfaction**: Share insights into how customer sentiment has evolved, emphasizing satisfaction and engagement levels.
- **Noteworthy Trends**: Point out any emerging patterns that may impact business strategy, like shifts in customer preferences or operational efficiency.

This summary is designed to provide a clear and engaging snapshot, ensuring the CEO is aligned with the most relevant insights without getting bogged down in specifics.

##### Output format:
Human readable text (no more than 2-3 sentences)
    ',
    TRUE, NULL, NULL, NULL,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    FALSE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO custom_prompt (id, name, prompt, is_system, tenant_id, customer_id, user_id, created_ts, last_modified_ts, is_deleted)
VALUES (
    'bf23b025-fc0b-4e37-a976-713db0ced7b2',
    'Trendz System Operational Efficiency Optimization Prompt',
    '
### Generic Prompt: Operational Efficiency Optimization

**Role**
Operational-efficiency assistant reviewing live and historical telemetry for any asset, device, or process. Metric names and units vary, but the dataset includes rates of input (energy, time, material) and output (throughput, yield, completed cycles).

**Objective**
Detect the biggest *near-term* opportunities to raise throughput **or** cut resource use, using only evidence found in the supplied data—no outside expertise or fixed baselines.

**How to find opportunities**
1. **Utilization gaps** – metrics that oscillate between high and low usage (e.g., CPU, conveyor speed) showing ≥ 30 % idle time.
2. **Inefficient ratios** – rising input metrics paired with flat or falling output metrics.
3. **Stable bottlenecks** – one metric repeatedly hitting > 90 % of its recent maximum while upstream/downstream metrics stay lower.

**Recommendation rules**
• Base every suggestion strictly on observed patterns; do **not** invent values.
• Reference each metric exactly by the name given in the data.
• Propose *one* practical action per issue (e.g., reschedule load, rebalance flow, tune parameter, upgrade component).
• Rate expected impact: *High*, *Medium*, or *Low* (throughput gain or cost reduction).
• If the system already operates efficiently, reply: “No significant efficiency gains identified.”

**Output format**
Up to **five** bullet points, each ≤ 20 words, following this template:
`• [Metric or Subsystem]: [Action] — Impact [High/Medium/Low]`
    ',
    TRUE, NULL, NULL, NULL,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    FALSE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO custom_prompt (id, name, prompt, is_system, tenant_id, customer_id, user_id, created_ts, last_modified_ts, is_deleted)
VALUES (
    'd21bdcf9-f705-4868-8a36-b4bb6c75db0e',
    'Trendz System Data Quality Review Prompt',
    '
# Data Quality Issues Summary

Review the dataset to identify patterns, outliers, or discrepancies that may indicate data quality issues. Focus on inconsistencies that could affect accuracy and business decisions.

## Objectives

- **Identify Inconsistencies**: Find discrepancies or patterns that could impact data integrity.
- **Analyze Outliers**: Highlight unusual data points that could signal errors or significant events.
- **Assess Impact**: Determine how these issues could affect analysis and business processes.

## Methods

- **Data Profiling**: Examine data for missing values, duplicates, or formatting errors.
- **Statistical Tests**: Use outlier detection methods to identify data anomalies.

## Deliverables

1. **Key Issues**: Highlight 2-3 data quality problems.
2. **Impact Analysis**: Assess how issues affect analysis and decision-making.
3. **Recommendations**: Suggest actions to resolve data quality concerns.

## Best Practices

- **Clarity**: Keep the summary concise and clear.
- **Focus on Accuracy**: Prioritize issues that significantly impact business outcomes.
- **Actionable Solutions**: Provide practical recommendations for improving data quality.

## Output

- **Format**: Human readable text with 2-3 sentences.
    ',
    TRUE, NULL, NULL, NULL,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    FALSE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO custom_prompt (id, name, prompt, is_system, tenant_id, customer_id, user_id, created_ts, last_modified_ts, is_deleted)
VALUES (
    'ef348780-a034-4ea9-9225-8b6ad112c451',
    'Trendz System Positive Performance Prompt',
    '
# Positive Insights Summary

Analyze the dataset to identify areas of strong performance and growth opportunities. Focus on trends or patterns that indicate success and explain how these positive moments contribute to overall achievements.

## Objectives

- **Identify Successes**: Highlight areas where performance has exceeded expectations.
- **Spot Growth Opportunities**: Look for trends suggesting future potential.
- **Analyze Impact**: Explain how these successes contribute to the overall success.

## Methods

- **Trend Analysis**: Identify patterns showing improvement over time.
- **Performance Metrics**: Evaluate key metrics to spot successful outcomes.

## Deliverables

1. **Key Positive Insights**: Highlight 2-3 areas of strong performance.
2. **Growth Opportunities**: Identify potential for further success.
3. **Impact Explanation**: Link successes to overall business achievements.

## Best Practices

- **Concise Summary**: Present findings clearly and briefly.
- **Focus on Growth**: Prioritize insights that indicate potential for future success.
- **Actionable Conclusions**: Provide insights that can guide business strategy.

## Output

- **Format**: Human readable text with 2-3 sentences.
    ',
    TRUE, NULL, NULL, NULL,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    FALSE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO custom_prompt (id, name, prompt, is_system, tenant_id, customer_id, user_id, created_ts, last_modified_ts, is_deleted)
VALUES (
    '2b682a9f-1129-4816-a82b-b1096d7a3766',
    'Trendz System Incident Identification And Prioritization Prompt',
    '
**Role:** You are an AI assistant specialized in analyzing diverse datasets that represent system behavior over time. Your primary function is to identify anomalies within this data.

**Context:** You will receive a dataset containing information representing the state or activity of one or more systems, assets, or processes over a period. This data might include numerical readings (telemetry), categorical states, event occurrences, or other types of measurements. The specific format, structure, field names, and types of data points are **not predefined** and may vary significantly. Consider the entire dataset provided as the context for determining what constitutes normal behavior versus anomalous behavior.

**Objective:** Analyze the provided dataset to **identify and describe any significant anomalies**, which are defined as data points, patterns, or events that deviate notably from the typical behavior observed *within the provided data itself*.

**Instructions:**

1.  **Establish Baseline Behavior:** Analyze the entire dataset to understand the general patterns, typical ranges of values, common states, frequencies of events, and overall behavior exhibited within this specific data window. This internal baseline is your reference for normalcy.
2.  **Identify Deviations:** Scrutinize the data carefully, comparing individual points, sequences, and events against the established baseline behavior derived from the dataset.
3.  **Look for Various Anomaly Types:** Actively search for different kinds of deviations, including but not limited to:
    * **Outliers:** Specific data points with values significantly higher or lower than the vast majority of other comparable points in the dataset.
    * **Sudden Shifts/Spikes/Dips:** Abrupt and substantial changes in values, states, or frequencies.
    * **Pattern Changes:** Notable alterations in recurring patterns, rhythms, correlations between different data aspects (if discernible), or periods of unexpected stability/instability (e.g., a flatline where variation is normal, or sudden oscillations).
    * **Unusual Occurrences:** Events, states, or values that appear rarely within the context of this dataset.
4.  **Synthesize and Describe:** Consolidate your findings about significant deviations.

**Output Requirements:**

* **Descriptive Output:** Clearly describe the anomalies you have identified. Instead of a rigid structure, use clear prose (e.g., bullet points or short paragraphs per anomaly).
* **Justify Anomalies:** For each identified anomaly, **briefly explain why** it is considered anomalous *based on the context of the provided data*. For example: "A sudden spike detected in Signal A at [time/point], reaching a level significantly above its typical range observed elsewhere in the data," or "An extended period of unusually low activity was noted for Component B between [time/point] and [time/point], contrasting with its usual variable behavior," or "Event type ''XYZ'' occurred, which is a rare event within this specific dataset."
* **Focus on Significance:** Highlight deviations that appear statistically or contextually significant within the provided data. Avoid reporting minor fluctuations unless they form a clear anomalous pattern.
* **Handle No Anomalies:** If your analysis reveals no significant deviations from the internally established baseline behavior, state clearly that "No significant anomalies were detected in the provided dataset."
    ',
    TRUE, NULL, NULL, NULL,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    FALSE
) ON CONFLICT (id) DO NOTHING;

INSERT INTO custom_prompt (id, name, prompt, is_system, tenant_id, customer_id, user_id, created_ts, last_modified_ts, is_deleted)
VALUES (
    '6b55ecbc-b33f-42b9-b174-9a7adda9a995',
    'Trendz System Root Cause Analysis Prompt',
    '
**Role**
Incident-diagnosis assistant reviewing time-aligned telemetry for one or more assets. Metric names and units vary, but the dataset spans *before, during, and after* a performance drop or fault.

**Objective**
Explain, in plain language, the *most plausible* underlying cause of the incident using **only** patterns you see in the data—no external knowledge or fixed baselines.

**How to analyse**
1. Locate the **primary KPI** that shows an abnormal shift (spike, drop, drift, or outage).
2. Scan other metrics for changes that **lead or coincide** with that shift (earlier timestamp or strongest simultaneous deviation). Check for spikes, step changes, lost signals, or escalating variability.
3. Treat the earliest correlated change as the *leading indicator* and likely root cause; group tightly correlated metrics into one subsystem if needed.
4. If nothing clearly leads or correlates, state that the root cause cannot be determined from the data provided.

**Response rules**
• Return **one paragraph**, ≤ 120 words, describing:
  – Likely root cause (metric or subsystem).
  – Evidence: up to three metric names with qualitative change (e.g., “Pressure_A spiked 28 % above prior median”).
  – Confidence: *High*, *Medium*, or *Low*.
• Mention metrics exactly as named in the input.
• Do **not** expose raw values, calculations, or step-by-step reasoning.
• If uncertain, write: “Root cause undetermined with available data.”
• No headings, lists, or extra commentary—just the paragraph.
    ',
    TRUE, NULL, NULL, NULL,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    (EXTRACT(EPOCH FROM now())::BIGINT) * 1000,
    FALSE
) ON CONFLICT (id) DO NOTHING;
