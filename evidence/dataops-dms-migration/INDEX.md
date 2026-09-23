# Evidence: end-to-end DMS migration (PostgreSQL → S3 data lake)

Lab run against the deployed [`aws-enterprise-dataops-migration-pipeline`](https://github.com/TreyWright360/aws-enterprise-dataops-migration-pipeline) stack.

| Field | Record |
| --- | --- |
| Date and region | 2026-09-23, `us-east-1` |
| Code revision | `aws-enterprise-dataops-migration-pipeline@` five fix commits between 18:00–19:40 UTC (see below); final deploy run [35910137380](https://github.com/TreyWright360/aws-enterprise-dataops-migration-pipeline/actions/runs/35910137380) |
| What was tested | A real `full-load-and-cdc` DMS task moving data from a live RDS PostgreSQL source into the S3 Parquet data lake |
| Seeding | The source database was empty (freshly created). Created one table (`public.orders`) and inserted 5 rows via a **temporary, SSM-only jump host** (no SSH key, no public IP exposure of the database) — the database itself was never made publicly accessible. Jump host, its IAM role, and all temporary security-group rules were deleted immediately after seeding. |
| Result | `FullLoadRows: 5`, `FullLoadErrorRows: 0`, `TableState: "Table completed"`. Full load ran in 0.285s. |
| Validation | Downloaded the resulting Parquet object (`public/orders/LOAD00000001.parquet`, 2217 bytes, valid `PAR1` header/footer) directly from S3 and confirmed the actual seeded values — customer names (`Alicia Chen`, `Sofia Ahmed`, ...) and product names (`Wireless Mouse`, ...) — are present in the file's raw data, not just that a file of the right size exists. |
| Limits | Only a full load was exercised; no ongoing change was made to the source after the load to test CDC (change data capture) apply behavior. Cross-region replication of this object to the DR bucket, and the Glue SCD2 transformation job, were not run in this pass. Kinesis stream was deployed but has no consumer wired up — out of scope for this lab. |

## What broke on the way here (the real work)

The DMS pipeline could not be deployed at all before this lab — five real, sequential failures, each fixed and re-verified:

1. **Placeholder replication instance ARN and hardcoded source password.** The original code pointed `aws_dms_replication_task` at `arn:...:rep:EXAMPLE-REP-INSTANCE` and hardcoded `SecureDmsPass123!` — neither the instance nor the password's use was ever going to work. Fixed by provisioning a real source RDS instance and DMS replication instance, and generating the password with `random_password`.
2. **Missing account prerequisite.** DMS refuses to create any VPC resource without an account-level IAM role named exactly `dms-vpc-role`. AWS does not create this automatically; it was missing entirely. Added it in Terraform so the repo is reproducible from a clean account.
3. **Invalid instance class.** `dms.t3.micro` does not exist as a DMS replication instance class; the smallest available is `dms.t3.small`.
4. **Invalid partial task settings.** A partial `TargetMetadata` override in `replication_task_settings` caused `CreateReplicationTask` to fail validation. Removed it in favor of DMS's complete default settings.
5. **No network path to S3.** The replication instance is deliberately not publicly accessible, so it had no route to S3's API through the default VPC's Internet Gateway (a private-IP-only network interface cannot use an IGW route). The target endpoint connection test failed with a generic "Failed to connect to database" error until a free **S3 Gateway VPC endpoint** was added — the more secure fix, versus the alternative of just making the instance publicly accessible.

Each of these is a real deployment blocker that existed in the repository before this session, not a hypothetical "production improvement." The commit history in the repo has the fix for each.

## Teardown

Jump host, its IAM role/instance profile, and temporary security-group rules: deleted immediately after seeding (see above). The DMS replication task was stopped after the full load completed (no ongoing CDC needed for this lab). The rest of the stack (RDS, DMS instance, S3 buckets, Glue, Kinesis) remains running for further testing/filming and has not been torn down as of this evidence record.
