# Role Runbook: Amazon EKS Platform Engineer & Kubernetes SRE

**Target Job Titles:** Cloud Platform Engineer | Kubernetes SRE | Amazon EKS Infrastructure Specialist  
**Core Responsibility:** Provisioning secure EKS cluster infrastructure, managing Helm deployment charts, and debugging container pod crashes using CloudWatch, Prometheus, and Grafana.

---

## 🚨 Scenario: EKS Workload CrashLoopBackOff & Worker Node Pod Evictions

* **Trigger:** Prometheus / Grafana Alert: `KubePodCrashLooping` and `NodeMemoryPressure > 85%` on the primary EKS cluster worker nodes.
* **Business Impact:** Microservice API error rates spike; pods are unable to schedule due to resource starvation.

---

## 🛠️ Step-by-Step Triage & Resolution Protocol

### Phase 1: Rapid Kubernetes Cluster Diagnostics
1. **Identify Failing Pods and Namespaces:**
   ```bash
   kubectl get pods --all-namespaces --field-selector status.phase!=Running
   ```
2. **Inspect Container Termination Reasons & Logs:**
   ```bash
   kubectl describe pod <POD_NAME> -n <NAMESPACE>
   kubectl logs <POD_NAME> -n <NAMESPACE> --previous
   ```
   *Look for `OOMKilled (Exit Code 137)` or missing IAM IRSA (IAM Roles for Service Accounts) permissions.*

### Phase 2: Node Group Scaling & Resource Requests / Limits
1. **Inspect Worker Node Memory Utilization:**
   ```bash
   kubectl top nodes
   kubectl top pods -n <NAMESPACE>
   ```
2. **Adjust Pod Resource Requests & Limits in Helm Chart:**
   * Ensure memory requests reflect true baselines with headroom to prevent kernel OOM-killer evictions:
     ```yaml
     resources:
       requests:
         memory: "512Mi"
         cpu: "250m"
       limits:
         memory: "1024Mi"
         cpu: "500m"
     ```

### Phase 3: IAM Roles for Service Accounts (IRSA) Verification
1. **Verify Pod Service Account Annotation:**
   * Confirm the pod's service account is mapped to the correct AWS IAM Role ARN:
     ```yaml
     apiVersion: v1
     kind: ServiceAccount
     metadata:
       annotations:
         eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/EKS-Microservice-Role
     ```

### Phase 4: Observability Verification in Grafana
1. Open the **Kubernetes Cluster Monitoring Dashboard** in Grafana.
2. Confirm that pod restarts return to `0` and worker node CPU/memory utilization stabilizes below `70%`.

---

## 🎤 How to Explain This Runbook in Interviews
> *"In containerized cloud platforms on Amazon EKS, stability depends on proper resource governance. When pods enter `CrashLoopBackOff`, my runbook diagnoses whether it's an `OOMKilled` memory limit issue, an unhandled application exception, or an IRSA IAM authentication failure, adjusts Helm resource configurations, and verifies recovery through Prometheus and Grafana dashboards."*
