# Role Runbook: Cloud Data Engineer & Pipeline Architect

**Target Job Titles:** Cloud Data Engineer | AWS Data Architect | ETL/ELT Pipeline Developer  
**Core Responsibility:** Guaranteeing zero-loss data ingestion, throughput SLAs, schema validation, and automated disaster recovery.

---

## 🚨 Scenario: High-Volume Ingestion Lag & Poison-Pill DLQ Backlog

* **Trigger:** CloudWatch Alert: `SQS Queue Depth > 10,000` and `DLQ ApproximateNumberOfMessagesVisible > 50`.
* **Business Impact:** Downstream analytics dashboards (Power BI / Athena) are stale; real-time ingestion delayed by 45 minutes.

---

## 🛠️ Step-by-Step Triage & Resolution Protocol

### Phase 1: Rapid Diagnostics (First 5 Minutes)
1. **Identify the Bottleneck Layer:**
   * Is it ingestion from S3, processing in Lambda/Glue, or writing to the target warehouse (Snowflake/Redshift)?
   * Run triage check:
     ```bash
     aws sqs get-queue-attributes --queue-url <PRIMARY_QUEUE_URL> \
       --attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible
     ```
2. **Check Lambda Concurrency & Throttles:**
   * Inspect CloudWatch metric `Throttles` and `ConcurrentExecutions` on the ETL Lambda.
   * If `Throttles > 0`, increase provisioned concurrency or adjust SQS batching window.

### Phase 2: Isolating Poison Pills from the DLQ
1. **Export and Snapshot DLQ Payloads:**
   ```bash
   python3 scripts/disaster_recovery.py --action backup-queue --queue <DLQ_URL>
   ```
2. **Inspect the Root Cause:**
   * Search for malformed JSON, schema drift (e.g. unexpected `null` in non-nullable field), or timestamp parsing errors.
3. **Deploy the Patch:**
   * Update Lambda parser code to safely handle the new field schema and redeploy via Terraform:
     ```bash
     cd terraform && terraform apply -auto-approve
     ```

### Phase 3: Redrive & Data Reconciliation
1. **Re-Inject Dead Letters back to Primary Queue:**
   ```bash
   python3 scripts/redrive_dlq.py --dlq-queue <DLQ_URL> --primary-queue <PRIMARY_URL> --redrive
   ```
2. **Verify Downstream Lakehouse State:**
   * Execute Athena query to verify record counts match upstream source files:
     ```sql
     SELECT count(*), date_trunc('hour', ingestion_time) 
     FROM curated_data_lake.orders 
     WHERE ingestion_time >= current_timestamp - interval '2' hour 
     GROUP BY 2;
     ```

---

## 🎤 How to Explain This Runbook in Interviews
> *"As a Cloud Data Engineer, I don't just write transformation scripts; I own pipeline reliability. When a poison pill enters an SQS queue, my runbook isolates the bad record without blocking the healthy batch (`ReportBatchItemFailures`), exports the payload for schema analysis, deploys the hotfix via Terraform, and redrives the messages with zero data loss."*
