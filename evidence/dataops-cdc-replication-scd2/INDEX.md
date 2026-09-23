# Evidence: CDC apply, cross-region replication, and SCD2 history

Three labs run against a fresh deploy of [`aws-enterprise-dataops-migration-pipeline`](https://github.com/TreyWright360/aws-enterprise-dataops-migration-pipeline), extending the [initial full-load migration evidence](../dataops-dms-migration/INDEX.md). Kinesis streaming was deliberately not tested here — no consumer is wired up to it, so a bare CLI put/get would prove nothing about a real streaming pipeline; that gap is left documented rather than faked.

## 1. CDC apply (ongoing change capture)

| Field | Record |
| --- | --- |
| Date and region | 2026-09-23, `us-east-1` |
| Setup | Full load of 5 seeded `orders` rows completed (0 errors), task entered ongoing `running`/CDC state |
| Change injected | 21:55:13Z — via a temporary SSM-only jump host: one `INSERT` (order 6, Jordan Kim), one `UPDATE` (order 1, Alicia Chen's quantity/total), one `DELETE` (order 3, Priya Nair) — all three DML types in one pass |
| Detected | 21:55:23Z — `describe-table-statistics` showed `AppliedInserts: 1, AppliedUpdates: 1, AppliedDeletes: 1`, all matching the injected changes exactly. ~10 seconds from source commit to DMS-applied. |
| Validation | Downloaded the resulting CDC Parquet file (`public/orders/2026/09/23/20260923-215605473.parquet`, written ~53s after the source change) and confirmed its actual content: an `Op` column (`I`/`U`/`D`), the new insert's real values (`Jordan Kim`, `Standing Desk`), and the update's new values for Alicia Chen. The delete row carries `Op=D` with only `order_id` populated and every other column null — this is how the DMS S3 target genuinely represents a delete, confirmed by inspecting the file directly, not assumed from documentation. |
| Limits | One batch of changes tested, not sustained/high-volume CDC throughput or lag under load. |

## 2. Cross-region replication (S3 CRR)

| Field | Record |
| --- | --- |
| Method | Uploaded a fresh, uniquely-timestamped marker object directly to the primary bucket (not part of the DMS pipeline) to get a clean, precise measurement rather than relying on same-second coincidence |
| Upload time | `2026-09-23T21:58:23Z` (primary bucket, `us-east-1`) |
| Replica confirmed | `2026-09-23T21:58:24Z` — the **replica object's own `LastModified` timestamp** (the authoritative one), `ReplicationStatus: REPLICA` on the copy, `us-west-2` |
| Measured lag | **~1 second.** (A polling loop checking every 2s took 23s to first *notice* it — that's polling overhead, not replication lag; the timestamps are what's real.) |
| Also observed | The actual DMS-migrated full-load Parquet file (`LOAD00000001.parquet`) showed `ReplicationStatus: COMPLETED` on the primary object, confirming CRR covers pipeline output, not just manually uploaded objects. |
| Limits | Single small object; no test of replication under sustained write volume or of the replica's independent restore path. |

## 3. Glue SCD2 transformation — real implementation, not a stub

**This required writing the actual transformation first.** The script in the repository (`src/scripts/pyspark_scd2_transform.py`) had every line of real logic commented out — it printed two strings and exited. Terraform also never uploaded the script to the location its own `aws_glue_job` resource pointed at, so the job as it existed could not have run successfully at all. Both are now fixed in the repo (see commit history): a real SCD2 implementation was written against the actual DMS S3 output schema (confirmed by downloading and inspecting the real Parquet files — an `Op` column only on CDC files, deletes carrying null non-key columns), and an `aws_s3_object` resource uploads the script.

| Field | Record |
| --- | --- |
| Job run | `jr_0a7b463cef764ea964454b1c451c0aa82e360a0b8edb04a69c18069542db0a10`, `SUCCEEDED`, 88s execution time |
| Result (from the job's own log) | `SCD2 rows produced: 7, currently active: 5` |
| Independently verified | Downloaded the curated output (`curated/orders_scd2/*.parquet`) and checked every row by hand: |

| order_id | customer | qty | total | start | end | current |
|---|---|---|---|---|---|---|
| 1 | Alicia Chen | 2 | 39.98 | 21:54:09 | 21:55:05 | **False** |
| 1 | Alicia Chen | 5 | 99.95 | 21:55:05 | — | **True** |
| 2 | Marcus Webb | 1 | 89.99 | 21:54:09 | — | True |
| 3 | Priya Nair | 3 | 74.97 | 21:54:09 | 21:55:05 | **False** |
| 4 | Devon Ruiz | 1 | 229.00 | 21:54:09 | — | True |
| 5 | Sofia Ahmed | 2 | 59.98 | 21:54:09 | — | True |
| 6 | Jordan Kim | 1 | 349.00 | 21:55:05 | — | True |

This is exactly correct: order 1 has two versions (old one closed at the update's timestamp, new one current), order 3 has one version correctly closed by the delete with no active successor, order 6 is a single current version from the insert, and the untouched orders (2, 4, 5) are unchanged single versions. 7 total versions, 5 currently active — matching the job's own reported counts.

| Field | Record |
| --- | --- |
| Limits | One batch of full-load + one CDC batch; no test of a second CDC batch layering a third version onto an existing key, or of concurrent job runs / idempotency on re-run. |

## Teardown

Jump host, its IAM role/instance profile, and temporary security-group rules were deleted immediately after each use. The stack itself (RDS, DMS, S3, Glue, Kinesis) remains running as of this evidence record for further testing.
