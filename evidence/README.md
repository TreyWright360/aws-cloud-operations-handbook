# Evidence rules

Each lab episode gets a directory such as `evidence/alb-504/` with an `INDEX.md` linking the artifacts. Use dated, redacted screenshots, command output, metric exports, and a short result summary. Add both failure and recovery proof. An empty folder or planned test is not evidence.

Minimum record:

| Field | Record |
| --- | --- |
| Date and region | When and where the controlled lab ran |
| Code revision | Commit SHA and Terraform plan/apply reference |
| Failure injection | Exact reversible change and start time |
| Observed symptom | User request result plus relevant AWS signal |
| Diagnosis | Evidence supporting the selected fault domain |
| Recovery | Corrective action and end time |
| Validation | Repeat user request, healthy targets, metrics after recovery |
| Limits | What the lab did not exercise |

Never publish AWS keys, tokens, account IDs, real customer data, sensitive log payloads, private endpoints, or Terraform state. Review screenshots and outputs before committing. Prefer short excerpts with timestamps over raw logs.
