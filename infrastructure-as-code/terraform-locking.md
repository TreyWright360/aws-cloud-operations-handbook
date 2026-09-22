# Terraform state lock recovery

**Evidence status:** DOCUMENTATION ONLY
**Applies to:** Every Terraform project, once its state backend and locking method are documented
**Video:** Not recorded

## Symptom and impact

`terraform plan` or `terraform apply` cannot acquire a state lock. This prevents concurrent state changes. Record the backend, workspace, lock ID, operation, owner, and creation time from the error without publishing sensitive state or credentials.

## Decision tree

1. **Identify the backend.** Inspect the active Terraform backend configuration and workspace. The five linked repositories do not currently declare an S3 backend in their checked-in root configurations; do not claim an S3 lock exists just because Terraform is used.
2. **Find the owner.** Check CI jobs, local operator sessions, and change records. If a writer is active, wait for it or coordinate with its owner. Do not unlock.
3. **Check whether the run finished badly.** If its process is gone, confirm the same state location and lock ID, then check whether the backend still reports a lock.
4. **Escalate if ownership is uncertain.** A wrong unlock can allow multiple writers against the same state.
5. **If stale and approved, unlock the exact ID.** Use `terraform force-unlock <LOCK_ID>` from the same backend and workspace. Avoid the non-interactive `-force` flag unless the change procedure requires it. Never use `-lock=false` to bypass an unresolved writer.
6. **Recheck before apply.** Run `terraform plan`, inspect unexpected changes and drift, then perform a controlled apply only after review.

## Read-only checks

```bash
terraform version
terraform workspace show
terraform providers
git status --short
```

Inspect the CI run status and backend configuration in the project. `terraform state pull` can expose secrets, so keep its output private and out of the portfolio; use only when necessary for a controlled backup or diagnosis.

## Lab simulation and recovery validation

Configure a disposable remote backend that supports locking. For a current S3 backend, use `use_lockfile = true` and enable bucket versioning. Begin one long operation, show that a second writer is blocked, then let the first end normally. For stale-lock practice, use a deliberately interrupted *lab* run, prove the process is gone, record the lock ID, unlock it, and capture a clean plan. Capture the backend configuration without bucket secrets or state data.

The permanent correction is usually concurrency control and reliable pipeline cleanup. `force-unlock` is a recovery tool for a proven stale lock, not a routine permanent fix.

## References

- [Terraform state locking](https://developer.hashicorp.com/terraform/language/state/locking)
- [Terraform force-unlock](https://developer.hashicorp.com/terraform/cli/commands/force-unlock)
- [Terraform S3 backend and lockfile](https://developer.hashicorp.com/terraform/language/backend/s3)
