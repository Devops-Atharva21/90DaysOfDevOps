# Day 49 -- DevSecOps Pipeline Security

## Overview

On Day 49, I enhanced my GitHub Actions CI/CD pipeline by integrating
security checks into every stage of the workflow.

## Task 1: Scan Docker Image for Vulnerabilities

### Objective

Scan the Docker image for known CVEs before deployment.

### What I Did

-   Added the Trivy GitHub Action after the Docker build and before
    deployment.
-   Configured the scan to fail on HIGH or CRITICAL vulnerabilities.
-   Reviewed the vulnerability report in GitHub Actions.

``` yaml
- name: Scan Docker Image for Vulnerabilities
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: <docker-username>/<image>:latest
    format: table
    exit-code: '1'
    severity: CRITICAL,HIGH
```

### Result

-   Base image: Alpine 3.23.5
-   Scan detected 8 HIGH vulnerabilities and 0 CRITICAL vulnerabilities.
-   Pipeline failed because HIGH vulnerabilities were configured to fail
    the build.

### Learning

Image scanning prevents vulnerable containers from reaching production.

------------------------------------------------------------------------

## Task 2: Enable Secret Scanning & Push Protection

### What I Did

-   Enabled Secret Protection.
-   Enabled Push Protection from GitHub repository settings.

### Difference

  -----------------------------------------------------------------------
  Secret Scanning                     Push Protection
  ----------------------------------- -----------------------------------
  Detects secrets already in the      Blocks pushes containing supported
  repository.                         secrets.

  Creates alerts.                     Prevents the secret from being
                                      committed.
  -----------------------------------------------------------------------

### If an AWS key is detected

-   Push is blocked.
-   GitHub creates a security alert.
-   Rotate the exposed key and use GitHub Secrets instead.

------------------------------------------------------------------------

## Task 3: Dependency Review

### What I Did

-   Added `actions/dependency-review-action@v4` to the PR pipeline.
-   Configured `fail-on-severity: critical`.
-   Learned Dependency Graph must be enabled for this action.

### Learning

Checks newly added dependencies for known vulnerabilities before
merging.

------------------------------------------------------------------------

## Task 4: Restrict Workflow Permissions

### What I Did

Added permissions blocks such as:

``` yaml
permissions:
  contents: read
```

or

``` yaml
permissions:
  contents: read
  pull-requests: write
```

### Learning

Limiting permissions follows the Principle of Least Privilege and
reduces the impact of compromised GitHub Actions.

------------------------------------------------------------------------

## Task 5: Complete DevSecOps Pipeline

``` text
PR Opened
   │
   ▼
Build & Test
   │
   ▼
Dependency Review
   │
   ▼
PR Approved & Merged
   │
   ▼
Build & Test
   │
   ▼
Docker Build
   │
   ▼
Trivy Image Scan
   │
Pass? ── Yes ─► Docker Push ─► Deploy
   │
   └── No ─► Stop Pipeline

Always Active:
- Secret Protection
- Push Protection
```

## Summary

By completing these tasks, I transformed a standard CI/CD pipeline into
a DevSecOps pipeline by integrating automated security checks for Docker
images, dependencies, secrets, and workflow permissions.

