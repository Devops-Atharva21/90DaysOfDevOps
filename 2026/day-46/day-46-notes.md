# Day 47 – Reusable Workflows & Composite Actions in GitHub Actions

## 🎯 Learning Objectives

- Understand reusable workflows and the `workflow_call` trigger.
- Create and call reusable workflows.
- Pass inputs, secrets, and outputs between workflows.
- Build and use a custom composite action.
- Compare reusable workflows with composite actions.

---

# Task 1: Understand `workflow_call`

## What is a Reusable Workflow?

A **reusable workflow** is a GitHub Actions workflow that can be called from another workflow. Instead of duplicating the same workflow logic across multiple repositories or workflows, you define it once and reuse it.

### Benefits

- Reduces duplicate code
- Easier maintenance
- Consistent CI/CD pipelines
- Reusable across repositories (if configured)

---

## What is the `workflow_call` Trigger?

`workflow_call` is a special trigger that allows one workflow to be invoked by another workflow.

Example:

```yaml
on:
  workflow_call:
```

Unlike `push` or `pull_request`, this workflow **cannot run by itself**.

It must be called from another workflow using:

```yaml
jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
```

---

## Reusable Workflow vs Regular Action (`uses:`)

| Reusable Workflow | Regular Action |
|-------------------|---------------|
| Runs one or more jobs | Runs inside a step |
| Triggered using `workflow_call` | Used with `uses:` |
| Can contain multiple jobs | Cannot contain jobs |
| Ideal for complete CI/CD pipelines | Ideal for reusable tasks |

---

## Where Must a Reusable Workflow Live?

Reusable workflows must be stored inside:

```text
.github/workflows/
```

Example:

```text
.github/workflows/reusable-build.yml
```

---

# Task 2: Create Your First Reusable Workflow

## Goal

Create:

```text
.github/workflows/reusable-build.yml
```

### Requirements

- Trigger using `workflow_call`
- Accept required inputs:
  - `app_name`
  - `environment` (default: staging)
- Accept required secret:
  - `docker_token`
- Checkout repository
- Print build information
- Verify the Docker token exists (without printing it)

---

## reusable-build.yml

```yaml
name: Reusable Build Workflow

on:
  workflow_call:
    inputs:
      app_name:
        description: "Application Name"
        required: true
        type: string

      environment:
        description: "Deployment Environment"
        required: false
        default: staging
        type: string

    secrets:
      docker_token:
        required: true

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Print Build Information
        run: |
          echo "Building ${{ inputs.app_name }} for ${{ inputs.environment }}"

      - name: Verify Docker Token
        run: |
          echo "Docker token is set: ${{ secrets.docker_token != '' }}"
```

---

## Expected Output

```text
Building my-web-app for production
Docker token is set: true
```

---

# Task 3: Create a Caller Workflow

## Goal

Create:

```text
.github/workflows/call-build.yml
```

---

## call-build.yml

```yaml
name: Call Reusable Workflow

on:
  push:
    branches:
      - main

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml

    with:
      app_name: "my-web-app"
      environment: "production"

    secrets:
      docker_token: ${{ secrets.DOCKER_TOKEN }}
```

---

## Workflow Flow

```
Push to main
      │
      ▼
call-build.yml
      │
      ▼
reusable-build.yml
```

---

## Expected Output

```text
Building my-web-app for production
Docker token is set: true
```

---

# Task 4: Add Outputs to the Reusable Workflow

## Goal

Return a generated build version back to the caller.

---

## Update reusable-build.yml

### Workflow Output

```yaml
outputs:
  build_version:
    description: "Generated Build Version"
    value: ${{ jobs.build.outputs.build_version }}
```

---

### Job Output

```yaml
jobs:
  build:
    outputs:
      build_version: ${{ steps.version.outputs.build_version }}
```

---

### Generate Version

```yaml
- name: Generate Build Version
  id: version
  run: |
    VERSION="v1.0-${GITHUB_SHA::7}"
    echo "Generated version: $VERSION"
    echo "build_version=$VERSION" >> "$GITHUB_OUTPUT"
```

---

## Update Caller Workflow

```yaml
print-version:
  runs-on: ubuntu-latest
  needs: build

  steps:
    - name: Print Build Version
      run: |
        echo "Build version: ${{ needs.build.outputs.build_version }}"
```

---

## Output Flow

```
Step Output
     │
     ▼
Job Output
     │
     ▼
Workflow Output
     │
     ▼
Caller Workflow
```

---

## Expected Output

```text
Generated version: v1.0-a1b2c3d
Build version: v1.0-a1b2c3d
```

---

# Task 5: Create a Composite Action

## Goal

Create:

```text
.github/actions/setup-and-greet/action.yml
```

---

## action.yml

```yaml
name: "Setup and Greet"

description: "Greets the user"

inputs:
  name:
    required: true

  language:
    required: false
    default: en

outputs:
  greeted:
    value: ${{ steps.greet.outputs.greeted }}

runs:
  using: composite

  steps:
    - id: greet
      shell: bash
      run: |
        if [ "${{ inputs.language }}" = "en" ]; then
          echo "Hello, ${{ inputs.name }}!"
        elif [ "${{ inputs.language }}" = "es" ]; then
          echo "Hola, ${{ inputs.name }}!"
        else
          echo "Hello, ${{ inputs.name }}!"
        fi

        echo "Current Date: $(date)"
        echo "Runner OS: $RUNNER_OS"

        echo "greeted=true" >> "$GITHUB_OUTPUT"
```

---

## Use the Composite Action

```yaml
name: Composite Action Demo

on:
  push:
    branches:
      - main

jobs:
  demo:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - id: greet
        uses: ./.github/actions/setup-and-greet

        with:
          name: "Atharva"
          language: en

      - name: Print Output
        run: |
          echo "Greeting completed: ${{ steps.greet.outputs.greeted }}"
```

---

## Expected Output

```text
Hello, Atharva!
Current Date: Sat Jul 4 ...
Runner OS: Linux
Greeting completed: true
```

---

# Task 6: Reusable Workflow vs Composite Action

| Feature | Reusable Workflow | Composite Action |
|----------|-------------------|------------------|
| Triggered By | `workflow_call` | `uses:` inside a step |
| Contains Jobs | ✅ Yes | ❌ No |
| Contains Multiple Steps | ✅ Yes | ✅ Yes |
| Lives In | `.github/workflows/` | `.github/actions/` |
| Accepts Secrets Directly | ✅ Yes | ❌ No (must be passed as inputs or environment variables) |
| Best For | Complete CI/CD pipelines | Reusable step logic |

---

# Folder Structure

```text
.github
├── actions
│   └── setup-and-greet
│       └── action.yml
│
└── workflows
    ├── reusable-build.yml
    ├── call-build.yml
    └── composite-action-demo.yml
```

---

# Key Takeaways

- `workflow_call` enables workflow reuse.
- Reusable workflows can contain multiple jobs.
- Composite actions can contain multiple steps but not multiple jobs.
- Use `inputs`, `secrets`, and `outputs` to exchange data.
- Use `$GITHUB_OUTPUT` to define outputs.
- Composite actions are ideal for reusable step sequences.
- Reusable workflows are ideal for reusable CI/CD pipelines.

---

# Quick Revision

### Reusable Workflow

- Trigger: `workflow_call`
- Multiple jobs
- Accepts inputs
- Accepts secrets
- Returns outputs
- Lives in `.github/workflows`

---

### Composite Action

- Triggered using `uses:`
- Multiple steps
- No jobs
- Accepts inputs
- Returns outputs
- Lives in `.github/actions`
