# RDS connectivity investigation

**Evidence status:** DOCUMENTATION ONLY
**Related project:** [Multi-AZ RDS module](https://github.com/TreyWright360/aws-multi-az-web-infrastructure/blob/main/modules/rds/main.tf)

## Symptom and impact

An application cannot connect to PostgreSQL, or connections fail after succeeding. Record the error text, application path, UTC time, endpoint, port, and whether existing sessions continue to work.

## Decision tree

1. Check the RDS instance status and recent events. If it is unavailable or failing over, record the event and wait for the endpoint to recover before proposing restore.
2. From the application network, resolve the RDS endpoint and test the TCP path to port 5432. Compare VPC route and app-to-DB security group rules. A DNS result alone does not prove the port is reachable.
3. If TCP succeeds, inspect authentication, credentials source, TLS requirements, and database user permissions. Do not print secrets.
4. If established sessions fail, inspect `DatabaseConnections`, CPU, `FreeStorageSpace`, and application pool size. Distinguish exhausted connections from storage or query load.
5. Use restore only when the database/data is actually unavailable or corrupted and the approved recovery objective requires it.

## Read-only checks

```bash
aws rds describe-db-instances --region <region> --db-instance-identifier <db-id>
aws rds describe-events --region <region> --source-type db-instance --source-identifier <db-id> --duration 60
```

The current multi-AZ project provisions RDS but its Apache static page does **not** connect to it. Add a small controlled application path and test data before claiming application-level RDS recovery. For a completed lab, capture the failing connection, network/database evidence, narrow correction, and a successful read and write. Redact endpoint names, account IDs, and credentials.
