# Day 44 – GitHub Secrets, Artifacts & Caching

## Objective

Learn how to securely manage sensitive data, share files between jobs, optimize workflow performance using caching, and execute real tests in GitHub Actions.

---

# Task 1: GitHub Secrets

## Goal

- Create a GitHub Secret named `MY_SECRET_MESSAGE`.
- Read the secret inside a workflow.
- Verify that the secret exists without printing its value.
- Attempt to print the secret directly and observe GitHub masking it.

## Workflow Example

```yaml
name: GitHub Secret Demo

on:
  workflow_dispatch:

jobs:
  secret-demo:
    runs-on: ubuntu-latest

    steps:
      - name: Check if secret exists
        run: |
          if [ -n "${{ secrets.MY_SECRET_MESSAGE }}" ]; then
            echo "The secret is set: true"
          else
            echo "The secret is set: false"
          fi
```

### Expected Output

```
The secret is set: true
```

### Printing the Secret

```yaml
- name: Print Secret
  run: |
    echo "${{ secrets.MY_SECRET_MESSAGE }}"
```

Output:

```
***
```

GitHub automatically masks secret values.

### Notes

- Secrets store sensitive information securely.
- Never hardcode passwords or API keys.
- Never print secrets in workflow logs.

---

# Task 2: Use Secrets as Environment Variables

## Goal

- Pass secrets as environment variables.
- Access them inside a shell script.
- Create:
  - DOCKER_USERNAME
  - DOCKER_TOKEN

## Workflow

```yaml
name: Secret as Environment Variable

on:
  workflow_dispatch:

jobs:
  use-secrets:
    runs-on: ubuntu-latest

    steps:
      - name: Pass secrets as environment variables
        env:
          DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
          DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}

        run: |
          echo "Docker user is available"

          if [ -n "$DOCKER_USERNAME" ]; then
            echo "Username is set: true"
          fi

          if [ -n "$DOCKER_TOKEN" ]; then
            echo "Docker token is set: true"
          fi
```

### Expected Output

```
Docker user is available
Username is set: true
Docker token is set: true
```

### Notes

- Use the `env` block to pass secrets securely.
- Access environment variables using:

```bash
$VARIABLE_NAME
```

Example:

```bash
echo "$DOCKER_USERNAME"
```

---

# Task 3: Upload Artifacts

## Goal

- Generate a file.
- Upload it using `actions/upload-artifact`.

## Workflow

```yaml
name: Upload Artifact Demo

on:
  workflow_dispatch:

jobs:
  upload-artifact:
    runs-on: ubuntu-latest

    steps:
      - name: Create report
        run: |
          echo "GitHub Actions Artifact Demo" > report.txt
          echo "Workflow completed successfully." >> report.txt
          echo "Date: $(date)" >> report.txt

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: test-report
          path: report.txt
```

### Verification

Go to:

```
Actions
    ↓
Workflow Run
    ↓
Artifacts
```

Download:

```
test-report.zip
```

### Notes

Artifacts store files generated during a workflow.

Examples:

- Logs
- Reports
- Build files
- Test results

---

# Task 4: Download Artifacts Between Jobs

## Goal

Share files between multiple jobs.

## Workflow

```yaml
name: Download Artifact Between Jobs

on:
  workflow_dispatch:

jobs:
  generate-report:
    runs-on: ubuntu-latest

    steps:
      - name: Create Report
        run: |
          echo "GitHub Actions Artifact Demo" > report.txt
          echo "Artifact created successfully." >> report.txt
          echo "Date: $(date)" >> report.txt

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: report-file
          path: report.txt

  use-report:
    runs-on: ubuntu-latest
    needs: generate-report

    steps:
      - name: Download Report
        uses: actions/download-artifact@v4
        with:
          name: report-file

      - name: Display Report
        run: |
          cat report.txt
```

### Expected Output

```
GitHub Actions Artifact Demo
Artifact created successfully.
Date: ...
```

### Notes

Artifacts are useful when:

- Passing build files to deployment jobs.
- Sharing test reports.
- Storing logs.
- Reusing generated files.

---

# Task 5: Run Real Tests in CI

## Goal

Run an actual script inside GitHub Actions.

## Python Script

**hello.py**

```python
print("Hello from GitHub Actions!")
print("Running tests...")
print("All tests passed!")
```

## Workflow

```yaml
name: Python CI Demo

on:
  workflow_dispatch:

jobs:
  run-python-script:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Run Script
        run: python hello.py
```

### Break the Pipeline

```python
print("Hello")

raise Exception("Intentional Failure")
```

Pipeline:

❌ Red

### Fix the Script

```python
print("Hello")
print("Everything is working!")
```

Pipeline:

✅ Green

### Notes

GitHub Actions automatically fails when a command exits with a non-zero exit code.

---

# Task 6: Caching

## Goal

Cache dependencies to speed up future workflow runs.

## requirements.txt

```text
requests==2.32.3
```

## Workflow

```yaml
name: Cache Demo

on:
  workflow_dispatch:

jobs:
  cache-example:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Cache pip packages
        uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
          restore-keys: |
            ${{ runner.os }}-pip-

      - name: Install Dependencies
        run: pip install -r requirements.txt
```

### First Run

```
Cache not found
Installing dependencies...
Saving cache...
```

### Second Run

```
Cache restored
Requirement already satisfied
```

### Notes

Caching stores downloaded dependencies so they don't need to be downloaded again.

Common caches:

- pip
- npm
- Maven
- Gradle

---

# Important Commands

## GitHub Secrets

```yaml
${{ secrets.SECRET_NAME }}
```

---

## Upload Artifact

```yaml
uses: actions/upload-artifact@v4
```

---

## Download Artifact

```yaml
uses: actions/download-artifact@v4
```

---

## Cache

```yaml
uses: actions/cache@v4
```

---

## Checkout Repository

```yaml
uses: actions/checkout@v4
```

---

## Setup Python

```yaml
uses: actions/setup-python@v5
```

---

# Key Takeaways

- Store sensitive data using GitHub Secrets.
- Pass secrets using environment variables.
- GitHub automatically masks secrets in logs.
- Upload artifacts to preserve workflow outputs.
- Download artifacts to share files between jobs.
- Run automated tests inside CI.
- Pipelines fail when commands return non-zero exit codes.
- Cache dependencies to speed up future workflow runs.
- Every GitHub Actions job runs on a fresh runner, so use artifacts or cache when files need to persist across jobs.

---

## Day 44 Summary

✅ GitHub Secrets

✅ Environment Variables

✅ Upload Artifacts

✅ Download Artifacts

✅ Run Real Tests

✅ Dependency Caching

🎯 You now understand how to securely manage secrets, transfer files between jobs, execute automated tests, and optimize GitHub Actions workflows for faster CI/CD pipelines.
