### DAY 40 TASK NOTES ###

### TASK 1

Objective

Set up a GitHub repository for practicing GitHub Actions by:

Creating a new public GitHub repository
Cloning the repository locally
Creating the GitHub Actions workflow directory structure
Task Details
Repository Name
github-actions-practice
Step 1: Create a Public GitHub Repository
Log in to GitHub.
Click New Repository.
Enter the repository name:
github-actions-practice
Select Public visibility.
Click Create Repository.
Step 2: Clone the Repository Locally

Copy the repository URL from GitHub and run:

git clone https://github.com/<username>/github-actions-practice.git

Example:

git clone https://github.com/johndoe/github-actions-practice.git

Move into the repository:

cd github-actions-practice
Step 3: Create the GitHub Actions Directory Structure

Create the required folders:

mkdir -p .github/workflows
Verify the Directory Structure

Run:

tree

Expected output:

.
└── .github
    └── workflows

2 directories, 0 files

If tree is not installed:

ls -R .github

Expected output:

.github:
workflows

.github/workflows:
Step 4: Add the Folder Structure to Git

Git does not track empty directories. Create a placeholder file:

touch .github/workflows/.gitkeep

Add the files:

git add .
Step 5: Commit the Changes
git commit -m "Initial GitHub Actions setup"
Step 6: Push to GitHub
git push origin main

Use master instead of main if your repository uses the master branch.


### TASK 2 

Objective

Create a simple GitHub Actions workflow that:

Triggers on every push
Has one job named greet
Runs on ubuntu-latest
Checks out the repository code
Prints a hello message
Verifies successful execution in the GitHub Actions tab
Workflow File Location
.github/workflows/hello.yml

Workflow Configuration
name: Hello Workflow

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Print Hello Message
        run: echo "Hello from GitHub Actions!"

Steps Performed
1. Created the Workflow Directory
mkdir -p .github/workflows

This command creates the GitHub Actions workflow directory.

2. Created the Workflow File
nano .github/workflows/hello.yml

Added the workflow configuration shown above.

3. Added the Workflow to Git
git add .github/workflows/hello.yml
4. Committed the Changes
git commit -m "Add hello workflow"
5. Pushed the Changes to GitHub
git push origin master

Use main instead of master if your repository uses the main branch.


### TASK 3

Objective

Learn the purpose of the main keywords used in a GitHub Actions workflow.

Keyword	Purpose
on:	Defines when the workflow should run (e.g., on push, pull request).
jobs:	Contains the jobs that the workflow will execute.
runs-on:	Specifies the operating system for the job (e.g., ubuntu-latest).
steps:	Lists the tasks to be executed in a job.
uses:	Runs a pre-built GitHub Action.
run:	Executes a shell command on the runner.
name:	Gives a readable name to a workflow, job, or step.
Example
name: Hello Workflow

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Print Hello Message
        run: echo "Hello from GitHub Actions!"

Key Learnings
on decides when the workflow starts.
jobs defines the work to be done.
runs-on chooses the runner OS.
steps are the tasks inside a job.
uses runs an existing action.
run executes commands.
name makes logs easier to read.

### TASK 4 

Objective

Update hello.yml to display additional information during workflow execution.

Tasks Completed
Printed the current date and time
Printed the branch name that triggered the workflow
Listed the files in the repository
Printed the runner's operating system
Updated Workflow
name: Hello

on:
  push:
    branches:
      - main

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Say Hello to User
        run: echo "Hello from GitHub Actions!"

      - name: Print Branch Name
        run: echo "The branch name is ${{ github.ref_name }}"

      - name: Print Current Date and Time
        run: date

      - name: List Files in Repository
        run: ls -la

      - name: Print Runner OS
        run: echo "Runner OS: ${{ runner.os }}"


### TASK 5 

Objective

Understand how GitHub Actions handles failures by intentionally adding a failing step, observing the error, and then fixing it.

Step 1: Add a Failing Step

Added a step with an invalid command:

- name: Intentional Failure
  run: wrongcommand

or

- name: Intentional Failure
  run: exit 1
Step 2: Push the Changes
git add .
git commit -m "Add failing step"
git push origin main
Step 3: Observe the Failure
Open the Actions tab on GitHub.
Select the latest workflow run.
Open the greet job.
Locate the failed step.
Example Error
wrongcommand: command not found
Error: Process completed with exit code 127.

or

Error: Process completed with exit code 1.
What Happened?
The workflow stopped at the failing step.
Any steps after the failed step were skipped.
The workflow status turned red ❌.
Step 4: Fix the Workflow

Removed the failing command or replaced it with a valid command:

- name: Fixed Step
  run: echo "Workflow fixed!"
Step 5: Push Again
git add .
git commit -m "Fix workflow failure"
git push origin main
Verification
Workflow completed successfully.
All steps executed.
Workflow status changed from red ❌ to green ✅.

