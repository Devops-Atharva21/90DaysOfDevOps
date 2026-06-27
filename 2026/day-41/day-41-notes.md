# Day 41 – Triggers & Matrix Builds

## Objective

Today I learned how GitHub Actions workflows can be triggered in different ways and how to run the same job across multiple environments using a matrix strategy.

---

# Task 1: Trigger on Pull Request

### Goal

Create a workflow that runs whenever a Pull Request is opened or updated against the `main` branch.

### Steps Performed

* Created `.github/workflows/pr-check.yml`
* Configured the workflow to trigger on:

  * Pull Request opened
  * Pull Request synchronized (updated)
* Printed the branch name using GitHub Actions variables.
* Created a new branch.
* Pushed a commit.
* Opened a Pull Request.
* Verified that the workflow ran automatically.

### Result

✅ The workflow appeared in the **Actions** tab.

✅ The workflow status was also visible on the Pull Request page.

---

# Task 2: Scheduled Trigger

### Goal

Run a workflow automatically every day.

### Schedule Used

```yaml
schedule:
  - cron: "0 0 * * *"
```

This runs every day at **12:00 AM UTC**.

### Cron Expression for Monday at 9 AM

```text
0 9 * * 1
```

Meaning:

* Minute → 0
* Hour → 9
* Day of Month → *
* Month → *
* Day of Week → Monday (1)

---

# Task 3: Manual Trigger

### Goal

Run a workflow manually from GitHub.

### Steps Performed

* Created `.github/workflows/manual.yml`
* Added the `workflow_dispatch` trigger.
* Created an input called `environment`.
* Accepted values such as:

  * staging
  * production
* Printed the selected environment in a workflow step.

### Result

✅ Workflow can be started manually from the **Actions** tab.

✅ The selected input value is displayed in the workflow logs.

---

# Task 4: Matrix Builds

### Goal

Run the same job using multiple Python versions.

### Matrix Configuration

Python Versions:

* Python 3.10
* Python 3.11
* Python 3.12

Each job:

* Installs Python
* Prints the installed version

### Result

GitHub Actions created **3 jobs** automatically.

Later, another matrix value was added:

Operating Systems:

* Ubuntu
* Windows

Total Jobs:

```
3 Python Versions × 2 Operating Systems = 6 Jobs
```

All jobs run in parallel.

---

# Task 5: Exclude & Fail-Fast

### Goal

Learn how to skip specific matrix combinations and understand the `fail-fast` option.

### Steps Performed

* Excluded one matrix combination.

  * Example:

    * Python 3.10 on Windows
* Set:


fail-fast: false


* Forced one job to fail.

### Observation

When `fail-fast` is **false**:

* One failed job does **not** stop the remaining jobs.
* All other jobs continue running until completion.

When `fail-fast` is **true** (default):

* If one matrix job fails, GitHub cancels the remaining running jobs to save time and resources.

---

# Key Learnings

* Workflows can be triggered by:

  * Push
  * Pull Request
  * Schedule (Cron)
  * Manual (`workflow_dispatch`)
* Matrix builds allow the same workflow to run on multiple versions or operating systems.
* Matrix jobs run in parallel.
* `exclude` removes unwanted matrix combinations.
* `fail-fast: false` allows all matrix jobs to finish even if one fails.

---

# Summary

Today I learned different ways to trigger GitHub Actions workflows and how matrix builds help test applications across multiple environments. I also understood how `exclude` and `fail-fast` affect matrix execution, making workflows more flexible and efficient.

