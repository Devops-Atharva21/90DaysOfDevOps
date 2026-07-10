# Day 47 – Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines

## Overview
Today I explored advanced GitHub Actions triggers used in real-world CI/CD pipelines, including Pull Request events, scheduled workflows, path filters, workflow chaining, and external event triggers.

---

## Task 1: Pull Request Event Types

**Workflow:** `pr-lifecycle.yml`

### Features
- Triggered on:
  - `opened`
  - `synchronize`
  - `reopened`
  - `closed`
- Printed:
  - PR event type
  - PR title
  - PR author
  - Source branch
  - Target branch
- Executed an additional step only when the PR was merged.

**Result:** Successfully verified workflow execution for different PR lifecycle events.

---

## Task 2: PR Validation Workflow

**Workflow:** `pr-checks.yml`

### Checks Performed
- File size validation (fails if a file is larger than **1 MB**)
- Branch name validation (`feature/*`, `fix/*`, `docs/*`)
- PR description validation (warns if empty)

**Result:** Workflow correctly validated pull requests before merging.

---

## Task 3: Scheduled Workflows (Cron)

**Workflow:** `scheduled-tasks.yml`

### Schedule
- Every Monday at **2:30 AM UTC**
- Every **6 hours**
- Manual execution using `workflow_dispatch`

### Health Check
- Performed a `curl` request and checked the response status.

### Notes
- **Every weekday at 9:00 AM IST:** `30 3 * * 1-5`
- **First day of every month at midnight UTC:** `0 0 1 * *`
- Scheduled workflows may be delayed or skipped on inactive repositories.

---

## Task 4: Path & Branch Filters

**Workflow:** `smart-triggers.yml`

### Features
- Trigger only when files inside:
  - `src/**`
  - `app/**`
- Ignore documentation changes:
  - `*.md`
  - `docs/**`
- Run only on:
  - `main`
  - `release/*`

### Notes
- **paths** → Run workflow only when specific files change.
- **paths-ignore** → Skip workflow when only ignored files are modified.

---

## Task 5: workflow_run (Workflow Chaining)

### Workflows
- `tests.yml`
- `deploy-after-tests.yml`

### Flow

```
Push
   ↓
Run Tests
   ↓
Success?
   ↓
Deploy
```

### Features
- Deployment started only after the **Run Tests** workflow completed successfully.
- Deployment was skipped when tests failed.

**Result:** Verified automatic workflow chaining.

---

## Task 6: repository_dispatch (External Trigger)

**Workflow:** `external-trigger.yml`

### Features
- Triggered using `repository_dispatch`
- Event type: `deploy-request`
- Printed:
  - Deployment environment from `client_payload`

### Trigger Command

```bash
gh api repos/<owner>/<repo>/dispatches \
  --method POST \
  --input payload.json
```

### Example Payload

```json
{
  "event_type": "deploy-request",
  "client_payload": {
    "environment": "production"
  }
}
```

### Result

```
Repository Dispatch Event Received
Environment: production
```

### Real-World Use Cases
- Slack approval triggers deployment.
- Monitoring tools trigger rollback or recovery.
- External CI/CD tools trigger GitHub workflows.
- Custom applications start deployments through the GitHub API.

---

## Key Learnings

- Used advanced `pull_request` events.
- Created PR validation workflows.
- Scheduled workflows using Cron expressions.
- Applied branch and path filters.
- Chained workflows using `workflow_run`.
- Triggered workflows externally using `repository_dispatch`.
- Learned how GitHub Actions supports event-driven CI/CD automation.
