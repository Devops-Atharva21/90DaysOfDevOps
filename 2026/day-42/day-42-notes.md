# Day 43 - GitHub Hosted & Self-Hosted Runners

## Objective

Learn how GitHub Actions uses GitHub-hosted and self-hosted runners to execute workflows.

---

## Task 1: GitHub-Hosted Runners

### Objective

Create a workflow with three jobs running on different operating systems.

### Runner Operating Systems

* Ubuntu (`ubuntu-latest`)
* Windows (`windows-latest`)
* macOS (`macos-latest`)

### Output

Each job printed:

* Operating System
* Runner Hostname
* Current User

### Learning

* GitHub-hosted runners are temporary virtual machines provided by GitHub.
* GitHub manages the infrastructure, updates, maintenance, and cleanup.
* Jobs run in parallel unless dependencies are defined using `needs`.

---

## Task 2: Explore Pre-installed Software

### Checked Versions

* Docker
* Python
* Node.js
* Git

### Learning

GitHub-hosted runners come with commonly used development tools already installed, reducing setup time and making workflows faster.

---

## Task 3: Set Up a Self-Hosted Runner

### Steps Performed

* Created a new self-hosted runner from the repository settings.
* Configured the runner on a Linux machine.
* Started the runner.
* Verified that it appeared as **Idle** with a green status in GitHub.

### Learning

A self-hosted runner executes workflow jobs on your own machine instead of GitHub's infrastructure.

---

## Task 4: Use a Self-Hosted Runner

### Workflow Actions

* Printed the machine hostname.
* Printed the current working directory.
* Created a file.
* Verified the file existed on the local machine after workflow execution.

### Learning

Self-hosted runners execute workflows directly on your own hardware or virtual machine.

---

## Task 5: Runner Labels

### Steps Performed

* Added a custom label to the self-hosted runner.
* Updated the workflow to use:

  ```yaml
  runs-on: [self-hosted, my-linux-runner]
  ```
* Triggered the workflow successfully.

### Learning

Labels help target specific runners when multiple self-hosted runners are available.

---

## Task 6: GitHub-Hosted vs Self-Hosted

| Feature             | GitHub-Hosted                     | Self-Hosted                                    |
| ------------------- | --------------------------------- | ---------------------------------------------- |
| Who manages it?     | GitHub                            | User / Organization                            |
| Cost                | Included with GitHub usage limits | User pays for hardware or cloud VM             |
| Pre-installed tools | Yes                               | User installs required tools                   |
| Good for            | General CI/CD workloads           | Custom environments and private infrastructure |
| Security Concern    | Managed by GitHub                 | User is responsible for security and updates   |

---

## Key Takeaways

* GitHub-hosted runners are managed by GitHub and are ready to use.
* Self-hosted runners run on your own machine or virtual server.
* Jobs execute in parallel by default.
* Runner labels help route jobs to the correct self-hosted machine.
* Choosing the right runner depends on project requirements, cost, and infrastructure.

