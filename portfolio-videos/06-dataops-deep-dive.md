# Video 6: Enterprise DataOps Migration Pipeline Deep Dive

> **Platform:** YouTube (long-form) / LinkedIn (cut down)
> **Duration:** 5–7 minutes
> **Repo:** [aws-enterprise-dataops-migration-pipeline](https://github.com/TreyWright360/aws-enterprise-dataops-migration-pipeline)
> **Evidence:** [evidence/dataops-dms-migration/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/dataops-dms-migration/INDEX.md), [evidence/dataops-cdc-replication-scd2/INDEX.md](https://github.com/TreyWright360/aws-cloud-operations-handbook/blob/main/evidence/dataops-cdc-replication-scd2/INDEX.md)

This is the most technically dense project in the portfolio — give it the most runtime.

---

## 0:00–0:20 — Hook
- **Visual:** Architecture diagram — source RDS, DMS replication instance, S3 target, Glue ETL job.
- **Say this:**
  > "A real database migration pipeline: full load, change data capture, cross-region replication, and a slowly-changing-dimension transform in Glue — all run against real AWS resources, not mocked."

## 0:20–1:10 — Full-load migration
- **Visual:** DMS console — replication task running, `Full Load` progress bar.
- **Say this:**
  > "First lab: a straightforward full-load migration from a source RDS instance to S3 through DMS. I hit two real infrastructure problems doing this that don't show up in a tutorial."
- **Show on screen:** the `dms-vpc-role` prerequisite error, then the fix (Terraform-provisioned role with a `time_sleep` for IAM propagation).

## 1:10–1:50 — The network problem
- **Visual:** DMS task stuck, error: "Failed to connect to database" (misleading generic message).
- **Say this:**
  > "This error looked like a database credentials problem. It wasn't — the replication instance is private, with no NAT, so it had no path to reach S3 at all. I fixed it with a free S3 Gateway VPC endpoint instead of making the instance public, which would've been the easy but worse answer."
- **Show on screen:** the VPC endpoint Terraform resource, then the task completing.

## 1:50–2:40 — Turning on CDC
- **Visual:** DMS task type switched to "Full load + CDC."
- **Say this:**
  > "Full load only gets you a point-in-time copy. Change data capture is what makes this a real pipeline — it streams ongoing inserts, updates, and deletes. Getting this working took finding the actual root cause behind a `CreateReplicationTask` failure: a missing `timestamp_column_name` setting on the S3 target endpoint, not the broken task-settings override I suspected first."
- **Show on screen:** a live insert/update/delete on the source table, then the corresponding CDC file landing in S3 with an `Op` column.

## 2:40–3:30 — Cross-region replication
- **Visual:** S3 console — two buckets, two regions, replication rule.
- **Say this:**
  > "On top of that, S3 cross-region replication keeps a copy of every landed file in a second region — the kind of control you'd actually want for a pipeline handling anything regulated or business-critical."
- **Show on screen:** a file appearing in both region buckets, timestamps a few seconds apart.

## 3:30–4:40 — Glue SCD2 transform
- **Visual:** Open `src/scripts/pyspark_scd2_transform.py`, highlight the window functions.
- **Say this:**
  > "The transform layer implements Slowly Changing Dimension Type 2 in PySpark — every row version gets an effective start and end date instead of being overwritten, so you can query what a record looked like at any point in history. This wasn't a stub I left — I wrote the actual windowing logic: partition by order ID, order by load timestamp, use `lead()` to compute each version's end date."
- **Show on screen:** Glue job run succeeding, then query results showing multiple versions of the same order_id with distinct date ranges.

## 4:40–5:20 — What I deliberately didn't test
- **Visual:** CASE-STUDY.md, the Kinesis line.
- **Say this:**
  > "I did not build or test a Kinesis streaming layer here, and I want to be specific about why: there's no consumer application in this project that would actually read from it. Standing up a stream with nothing reading from it wouldn't prove anything — it'd just be a screenshot. I'd rather tell you that directly than fake a green checkmark."

## 5:20–5:50 — Close / teardown
- **Visual:** Teardown terminal — DMS, RDS, S3, Glue, VPC endpoint all confirmed removed.
- **Say this:**
  > "Fully torn down and verified — no RDS instance, no DMS replication instance, no leftover S3 replication rules still billing."

---

## Production notes
- This is the longest script — if cutting for a LinkedIn version, keep 0:20–1:10 (full load), 2:40–3:30 (cross-region), and 4:40–5:20 (Kinesis honesty beat); cut CDC detail first since it's the hardest to follow without narration.
