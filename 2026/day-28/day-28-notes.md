### Task 1: Self-Assessment Checklist ###

## Self-Assessment Checklist

![Self Assessment Checklist](/home/atharva/Downloads/TASK-1.png)

***Reviewed my Linux, Shell Scripting, and Git/GitHub skills.
✅ Can do confidently
🟡 Need to revisit
❌ Haven't done yet

Category	                  Checklist Item	                                                        Status (✅/🟡/❌)
Linux	          Navigate the file system, create/move/delete files and directories	                           ✅
Linux	          Manage processes — list, kill, background/foreground	                                           ✅
Linux	          Work with systemd — start, stop, enable, check status of services	                               ✅
Linux	          Read and edit text files using vi/vim or nano	                                                   ✅
Linux	          Troubleshoot CPU, memory, and disk issues using top, free, df, du	                               ✅
Linux	          Explain the Linux file system hierarchy (/, /etc, /var, /home, /tmp, etc.)	                   ✅
Linux	          Create users and groups, manage passwords	                                                       ✅
Linux	          Set file permissions using chmod (numeric and symbolic)	                                       ✅
Linux	          Change file ownership with chown and chgrp	                                                   ✅
Linux	          Create and manage LVM volumes	                                                                   ✅
Linux	          Check network connectivity — ping, curl, netstat, ss, dig, nslookup	                           🟡
Linux	          Explain DNS resolution, IP addressing, subnets, and common ports	                               🟡
Shell Scripting	  Write a script with variables, arguments, and user input	                                       ✅
Shell Scripting	  Use if/elif/else and case statements	                                                           ✅
Shell Scripting	  Write for, while, and until loops	                                                               ✅
Shell Scripting	  Define and call functions with arguments and return values	                                   🟡
Shell Scripting	  Use grep, awk, sed, sort, uniq for text processing	                                           🟡
Shell Scripting	  Handle errors with set -e, set -u, set -o pipefail, trap	                                       🟡
Shell Scripting	  Schedule scripts with crontab	                                                                   🟡 
Git & GitHub	  Initialize a repo, stage, commit, and view history	                                           ✅
Git & GitHub	  Create and switch branches	                                                                   ✅
Git & GitHub	  Push to and pull from GitHub	                                                                   ✅
Git & GitHub	  Explain clone vs fork	                                                                           ✅
Git & GitHub	  Merge branches — understand fast-forward vs merge commit	                                       🟡
Git & GitHub	  Rebase a branch and explain when to use it vs merge	                                           🟡
Git & GitHub	  Use git stash and git stash pop	                                                               ✅
Git & GitHub	  Cherry-pick a commit from another branch	                                                       ✅
Git & GitHub	  Explain squash merge vs regular merge	                                                           🟡
Git & GitHub	  Use git reset (soft, mixed, hard) and git revert	                                               🟡
Git & GitHub	  Explain GitFlow, GitHub Flow, and Trunk-Based Development	                                       ❌
Git & GitHub	  Use GitHub CLI to create repos, PRs, and issues	                                               🟡

## Task 2: Revisit Weak Spots

### 1. Network Connectivity Commands
- Practiced using ping, curl, ss, dig, and nslookup.
- Revised how to troubleshoot basic network issues.

### 2. Shell Script Error Handling
- Revisited set -e, set -u, set -o pipefail, and trap.
- Understood how they improve script reliability.

### 3. Git Rebase
- Practiced rebasing a branch onto another branch.
- Learned how rebase creates a cleaner commit history.
- Reviewed conflict resolution during rebase.


## Task 3: Quick-Fire Questions

**1. What does chmod 755 script.sh do?**
Gives the owner read, write, and execute permissions, while the group and others get read and execute permissions.

**2. What is the difference between a process and a service?**
A process is a running instance of a program, while a service is a background process managed by the system.

**3. How do you find which process is using port 8080?**
Use:

ss -tulnp | grep 8080

**4. What does set -euo pipefail do in a shell script?**

* set -e: Exit on command failure.
* set -u: Treat unset variables as errors.
* set -o pipefail: Fail if any command in a pipeline fails.

**5. What is the difference between git reset --hard and git revert?**
git reset --hard removes commits and local changes, while git revert creates a new commit that undoes previous changes.

**6. What branching strategy would you recommend for a team of 5 developers shipping weekly?**
GitHub Flow, because it is simple and works well for frequent releases.

**7. What does git stash do and when would you use it?**
Temporarily saves uncommitted changes so you can switch branches without committing unfinished work.

**8. How do you schedule a script to run every day at 3 AM?**
Add the following entry to crontab:

0 3 * * * /path/to/script.sh

**9. What is the difference between git fetch and git pull?**
git fetch downloads changes without merging them, while git pull downloads and merges the changes into the current branch.

**10. What is LVM and why would you use it instead of regular partitions?**
LVM (Logical Volume Manager) provides flexible disk management, allowing volumes to be resized and managed more easily than traditional partitions.
