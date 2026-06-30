# Day 43 – Multi-Job Workflows, Environment Variables, Outputs & Conditionals

## Objective

Learn how GitHub Actions workflows become more powerful by using:

- Multiple jobs
- Job dependencies
- Environment variables
- GitHub context variables
- Job outputs
- Conditional execution
- Smart workflow design

---

# Task 1 – Multi-Job Workflow

## Goal

Create a workflow that contains three jobs.

```
build
   ↓
test
   ↓
deploy
```

Each job should run only after the previous one completes successfully.

---

## Workflow

**File**

```
.github/workflows/multi-job.yml
```

The workflow contains:

### Job 1 – Build

Prints

```
Building the app
```

---

### Job 2 – Test

Prints

```
Running tests
```

Runs only after **build** succeeds.

Uses

```yaml
needs: build
```

---

### Job 3 – Deploy

Prints

```
Deploying
```

Runs only after **test** succeeds.

Uses

```yaml
needs: test
```

---

## Workflow Dependency Chain

```
build
   │
   ▼
test
   │
   ▼
deploy
```

---

## Verification

Open

```
GitHub Repository
    → Actions
        → Select Workflow
```

The workflow graph should display

```
build → test → deploy
```

This confirms the dependency chain is working correctly.

---

# Notes

### What is `needs`?

`needs` creates dependencies between jobs.

Without `needs`

```
All jobs run in parallel.
```

With `needs`

```
A job waits until another job completes successfully.
```

Example

```yaml
needs: build
```

means

```
Run this job only after the build job succeeds.
```

---

# Task 2 – Environment Variables

## Goal

Understand environment variables at different scopes.

There are three levels.

---

## 1. Workflow Level

Available everywhere in the workflow.

Example

```yaml
env:
  APP_NAME: myapp
```

Accessible from every job and every step.

---

## 2. Job Level

Available only inside one job.

Example

```yaml
jobs:
  deploy:
    env:
      ENVIRONMENT: staging
```

---

## 3. Step Level

Available only for a single step.

Example

```yaml
steps:
  - name: Print Version
    env:
      VERSION: 1.0.0
```

---

## Expected Output

Print all three variables.

Example output

```
App Name : myapp
Environment : staging
Version : 1.0.0
```

---

# GitHub Context Variables

GitHub automatically provides useful information during workflow execution.

Examples

### Commit SHA

```yaml
${{ github.sha }}
```

Prints

```
f73cb98f13cb....
```

---

### Actor

```yaml
${{ github.actor }}
```

Prints

```
atharva
```

This tells who triggered the workflow.

---

## Notes

Environment variables are useful for

- Application names
- Environment names
- Ports
- URLs
- Version numbers
- Configuration values

GitHub context variables provide information about the repository, workflow, branch, commit, event, and user.

---

# Task 3 – Job Outputs

## Goal

Pass data from one job to another.

---

## Workflow

### Job 1

Generate today's date.

Store it as an output.

---

### Job 2

Read the output from Job 1.

Print the date.

Use

```yaml
needs.<job>.outputs.<output_name>
```

Example

```yaml
needs.build.outputs.today
```

---

## Workflow

```
Job 1
Generate Date
      │
      ▼
Job Output
      │
      ▼
Job 2
Print Date
```

---

## Why Pass Outputs Between Jobs?

Job outputs allow information produced by one job to be reused by another.

Common use cases

- Docker image tag
- Build version
- Release version
- Artifact name
- Deployment URL
- Generated file names
- Build number
- Today's date

Without outputs, jobs are isolated and cannot directly share data.

---

# Task 4 – Conditionals

GitHub Actions allows jobs and steps to execute only when specific conditions are met.

---

## Condition 1

Run a step only when the branch is **main**.

Example

```
Branch == main
```

If true

```
Run step
```

Otherwise

```
Skip step
```

---

## Condition 2

Run a step only if the previous step failed.

Useful for

- Cleanup
- Notifications
- Logging
- Error reporting

---

## Condition 3

Run a job only on **push** events.

Do not run during pull requests.

Useful when deployment should happen only after code is pushed.

---

## Condition 4

Use

```yaml
continue-on-error: true
```

### What does it do?

Normally

```
Step fails
↓

Job stops
```

With

```yaml
continue-on-error: true
```

```
Step fails
↓

Workflow continues

↓

Next steps still execute
```

Useful for

- Optional checks
- Experiments
- Non-critical validation
- Collecting logs without stopping the workflow

---

# Task 5 – Smart Pipeline

## Goal

Create a practical workflow.

File

```
.github/workflows/smart-pipeline.yml
```

---

## Requirements

Trigger

```
Push to any branch
```

---

### Jobs

```
lint
```

Runs independently.

---

```
test
```

Runs independently.

---

These two jobs execute in parallel.

```
lint          test
   \          /
    \        /
     \      /
      summary
```

---

### Summary Job

Runs only after

- lint
- test

using

```yaml
needs:
  - lint
  - test
```

---

The summary job prints

- Whether the push was made to the **main** branch
- Or to a **feature** branch
- The commit message

---

## Why Design Pipelines Like This?

Running independent jobs in parallel

- Reduces execution time
- Improves CI performance
- Makes workflows easier to maintain
- Allows deployments only after all validations pass

This is the workflow pattern commonly used in real-world DevOps projects.

---

# Key Takeaways

✅ Use `needs` to create job dependencies.

✅ Jobs without `needs` run in parallel.

✅ Environment variables can be defined at workflow, job, or step level.

✅ GitHub context variables provide workflow metadata like branch, actor, and commit SHA.

✅ Job outputs enable data sharing between jobs.

✅ Conditionals control when jobs and steps execute.

✅ `continue-on-error: true` allows workflows to continue even if a step fails.

✅ Parallel jobs make CI pipelines faster and more efficient.

✅ Summary jobs are useful for collecting results after multiple jobs finish.

---

# Files Created

```
.github/workflows/
│
├── multi-job.yml
├── environment-variables.yml
├── job-outputs.yml
├── conditionals.yml
└── smart-pipeline.yml
```

---

# Skills Learned

- Multi-job workflows
- Job dependencies (`needs`)
- Environment variables
- GitHub context variables
- Job outputs
- Conditional execution
- Parallel job execution
- Smart CI pipeline design
```
