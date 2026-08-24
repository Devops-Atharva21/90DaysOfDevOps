# Day 69 — Ansible Playbooks and Modules

## Overview

Ad-hoc Ansible commands are useful for quick checks, but **playbooks** are used for real automation.

A playbook is a YAML file that describes the desired state of servers:

- Which packages should be installed
- Which services should be running
- Which files should exist
- Which permissions should be applied
- Which actions should happen only when something changes

### Main idea

> **Write automation once, run it many times, and keep servers in the desired state.**

---

# 1. Ansible Playbook Basics

A simple playbook looks like this:

```yaml
---
- name: Install and start Nginx
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
```

## Important terms

| Term | Meaning |
|---|---|
| **Playbook** | YAML file containing automation |
| **Play** | Defines which hosts should be managed and what tasks belong to that group |
| **Task** | One unit of work |
| **Module** | Ansible component that performs the work |
| **Handler** | A special task that runs only when notified |
| **Inventory** | Defines the servers/groups Ansible manages |

---

# Task 1 — Your First Playbook

Create:

```text
install-nginx.yml
```

Example for Amazon Linux:

```yaml
---
- name: Install and start Nginx on web servers
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Start and enable Nginx
      service:
        name: nginx
        state: started
        enabled: true

    - name: Create a custom index page
      copy:
        content: "<h1>Deployed by Ansible - TerraWeek Server</h1>"
        dest: /usr/share/nginx/html/index.html
```

For Ubuntu, use `apt` instead of `yum`:

```yaml
apt:
  name: nginx
  state: present
```

## Run the playbook

```bash
ansible-playbook install-nginx.yml
```

## Understanding the output

Ansible commonly shows:

```text
ok       → Nothing needed to change
changed  → Ansible changed something
failed   → Task failed
skipped  → Task was skipped
unreachable → Ansible could not connect to the server
```

## Idempotency

Run the same playbook again.

On the first run, you may see:

```text
changed
```

On the second run, you should normally see:

```text
ok
```

This is called **idempotency**.

### Simple definition

> **Idempotency means running the same playbook multiple times produces the same desired state without making unnecessary changes.**

Example:

```text
First run:
Install Nginx → changed

Second run:
Nginx already installed → ok
```

## Verify Nginx

From a machine that can reach the web server:

```bash
curl http://SERVER_PUBLIC_IP
```

You should see:

```html
<h1>Deployed by Ansible - TerraWeek Server</h1>
```

---

# Task 2 — Understand Playbook Structure

Basic structure:

```yaml
---
- name: Play name
  hosts: web
  become: true

  tasks:
    - name: Task name
      module_name:
        key: value
```

## Line-by-line explanation

### `---`

```yaml
---
```

Marks the beginning of a YAML document.

### Play name

```yaml
- name: Install and start Nginx
```

This is the name of the **play**.

It makes the Ansible output easier to understand.

### `hosts`

```yaml
hosts: web
```

Defines which inventory group the play should run against.

For example:

```text
hosts: web
```

means run on servers in the `web` group.

### `become`

```yaml
become: true
```

Tells Ansible to use privilege escalation, usually `sudo`.

This is commonly required for tasks such as:

- Installing packages
- Editing system files
- Starting services
- Creating directories under `/opt` or `/etc`

### `tasks`

```yaml
tasks:
```

Contains the list of tasks that Ansible should execute.

### Task

```yaml
- name: Install Nginx
```

A task is **one unit of work**.

### Module

```yaml
apt:
```

The module tells Ansible **how to perform the task**.

---

## Play vs Task

### Play

A play defines:

- Which hosts to target
- Privilege settings
- Tasks to execute

Example:

```yaml
- name: Configure web servers
  hosts: web
  become: true
```

### Task

A task performs one specific action:

```yaml
- name: Install Nginx
  apt:
    name: nginx
    state: present
```

### Can a playbook have multiple plays?

**Yes.**

Example:

```yaml
---
- name: Configure web servers
  hosts: web
  tasks:
    ...

- name: Configure app servers
  hosts: app
  tasks:
    ...

- name: Configure database servers
  hosts: db
  tasks:
    ...
```

This allows one playbook to manage different server groups.

---

## `become` at play vs task level

### Play level

```yaml
- name: Configure servers
  hosts: web
  become: true
```

All tasks in the play use privilege escalation by default.

### Task level

You can also enable it for only one task:

```yaml
- name: Restart Nginx
  become: true
  service:
    name: nginx
    state: restarted
```

Task-level settings are useful when only a specific task needs elevated privileges.

---

## What happens if a task fails?

By default, if a task fails on a host:

```text
Task 1 → OK
Task 2 → FAILED
Task 3 → not executed on that host
```

Ansible normally stops executing remaining tasks for that host.

Other hosts can continue unless the play is configured to stop more broadly.

---

# Task 3 — Essential Ansible Modules

These modules are useful in almost every Ansible project.

---

## 3.1 `apt` / `yum` — Package Management

Use package modules to install or remove software.

### Ubuntu/Debian

```yaml
- name: Install multiple packages
  apt:
    name:
      - git
      - curl
      - wget
      - tree
    state: present
```

### Amazon Linux/RHEL-based systems

```yaml
- name: Install multiple packages
  yum:
    name:
      - git
      - curl
      - wget
      - tree
    state: present
```

### Common states

```yaml
state: present
```

Package should be installed.

```yaml
state: absent
```

Package should be removed.

### Remember

```text
Ubuntu/Debian → apt
Amazon Linux 2 → yum
Amazon Linux 2023 → dnf
```

---

# 3.2 `service` — Manage Services

Use `service` to start, stop, restart, and enable services.

```yaml
- name: Ensure Nginx is running
  service:
    name: nginx
    state: started
    enabled: true
```

### Important options

```yaml
state: started
```

Start the service if it is not running.

```yaml
state: stopped
```

Stop the service.

```yaml
state: restarted
```

Restart the service.

```yaml
enabled: true
```

Start the service automatically when the server boots.

---

# 3.3 `copy` — Copy Files

The `copy` module copies files from the **Ansible control node** to managed servers.

```yaml
- name: Copy config file
  copy:
    src: files/app.conf
    dest: /etc/app.conf
    owner: root
    group: root
    mode: '0644'
```

### Direction

```text
Ansible Controller
      |
      | src: files/app.conf
      ↓
Managed Server
      |
      | dest: /etc/app.conf
```

`src` normally refers to the file on the control node.

### Common options

```yaml
owner: root
group: root
mode: '0644'
```

These control ownership and permissions.

---

# 3.4 `file` — Files and Directories

Use `file` to create directories and manage permissions.

```yaml
- name: Create application directory
  file:
    path: /opt/myapp
    state: directory
    owner: ubuntu
    mode: '0755'
```

### Important options

```yaml
path:
```

Location of the file or directory.

```yaml
state: directory
```

Make sure the directory exists.

```yaml
owner:
```

Set the owner.

```yaml
mode:
```

Set permissions.

### Common states

```text
directory → Create/manage directory
file      → Manage an existing file
absent    → Remove the item
touch     → Create an empty file if needed
```

---

# 3.5 `command` — Run Commands

The `command` module runs a command without a shell.

Example:

```yaml
- name: Check disk space
  command: df -h
  register: disk_output

- name: Print disk space
  debug:
    var: disk_output.stdout_lines
```

## What is `register`?

```yaml
register: disk_output
```

Stores the command result in a variable named `disk_output`.

You can then use:

```yaml
disk_output.stdout
```

or:

```yaml
disk_output.stdout_lines
```

---

# 3.6 `shell` — Run Shell Commands

The `shell` module runs commands through a shell.

Example:

```yaml
- name: Count running processes
  shell: ps aux | wc -l
  register: process_count

- name: Show process count
  debug:
    msg: "Total processes: {{ process_count.stdout }}"
```

Here:

```text
ps aux | wc -l
```

uses the pipe (`|`), which is a shell feature.

---

## `command` vs `shell`

| Feature | `command` | `shell` |
|---|---|---|
| Runs commands | Yes | Yes |
| Shell features | No | Yes |
| Pipes `|` | No | Yes |
| Redirects `>` | No | Yes |
| Variables/expansion | Limited | Shell-supported |
| Safer/simple choice | Usually | Use when needed |

### Which should you use?

Prefer:

```yaml
command:
```

when you only need to execute a simple command.

Use:

```yaml
shell:
```

when you specifically need shell features such as:

```text
|
>
>>
&&
```

### Best practice

If an Ansible module can perform the job directly, prefer the module instead of `command` or `shell`.

For example, use:

```yaml
service:
  name: nginx
  state: started
```

instead of:

```yaml
shell: systemctl start nginx
```

---

# 3.7 `lineinfile` — Manage a Single Line

Use `lineinfile` when you need to add or modify one line in a file.

```yaml
- name: Set timezone in environment
  lineinfile:
    path: /etc/environment
    line: 'TZ=Asia/Kolkata'
    create: true
```

This ensures the line exists in the file.

### `create: true`

If the file doesn't exist, Ansible creates it.

This module is useful for:

- Environment variables
- Configuration lines
- Settings
- Simple configuration changes

---

# Task 4 — Handlers

Handlers are special tasks that run **only when another task notifies them**.

They are useful when a configuration change requires a service restart.

Example:

```yaml
- name: Deploy Nginx config
  copy:
    src: files/nginx.conf
    dest: /etc/nginx/nginx.conf
  notify: Restart Nginx
```

Handler:

```yaml
handlers:
  - name: Restart Nginx
    service:
      name: nginx
      state: restarted
```

## How it works

```text
Copy Nginx config
       |
       | file changed?
       |
      YES
       ↓
notify: Restart Nginx
       |
       ↓
Restart Nginx handler
```

If the file doesn't change:

```text
Copy Nginx config
       |
       | no change
       ↓
Handler not triggered
```

### First run

The configuration file may be new:

```text
Deploy config → changed
Restart handler → runs
```

### Second run

If nothing changed:

```text
Deploy config → ok
Restart handler → does not run
```

This avoids unnecessary service restarts.

## Important

The name must match exactly.

Correct:

```yaml
notify: Restart Nginx

handlers:
  - name: Restart Nginx
```

Incorrect:

```yaml
notify: Restart Nginx

handlers:
  - name: Reatrt Nginx
```

Even a spelling mistake causes the handler to be unavailable.

---

# Task 5 — Dry Run, Diff, and Verbosity

Before changing production servers, preview what Ansible plans to do.

---

## 5.1 Check Mode / Dry Run

```bash
ansible-playbook install-nginx.yml --check
```

This asks Ansible to simulate changes without normally applying them.

### Purpose

Use it to answer:

> "What would Ansible change?"

---

## 5.2 Diff Mode

```bash
ansible-playbook nginx-config.yml --check --diff
```

This combines:

```text
--check → Preview changes
--diff  → Show file differences
```

For configuration files, this is especially useful.

### Why `--check --diff` is important

It helps you review configuration changes **before applying them**.

Think:

```text
Production server
      ↑
      |
Check + Diff
      |
Review changes
      |
Approve
      |
Run normally
```

It reduces the chance of accidentally deploying an incorrect configuration.

> Note: Check mode is a simulation, not a perfect prediction. Some modules or commands may not fully support check mode.

---

## 5.3 Verbosity

Increase Ansible's output when debugging.

### Normal

```bash
ansible-playbook install-nginx.yml
```

### Verbose

```bash
ansible-playbook install-nginx.yml -v
```

### More verbose

```bash
ansible-playbook install-nginx.yml -vv
```

### Very detailed connection/debug information

```bash
ansible-playbook install-nginx.yml -vvv
```

Use higher verbosity when troubleshooting:

- SSH problems
- Inventory problems
- Module failures
- Variables
- Connection issues

---

## 5.4 Limit Hosts

Run the playbook only against a specific host:

```bash
ansible-playbook install-nginx.yml --limit web-server
```

This is useful when you don't want to affect every server.

Example:

```text
Inventory:
web-server-1
web-server-2
web-server-3

--limit web-server-1
        ↓
Only web-server-1 is targeted
```

---

## 5.5 List Hosts

See which hosts would be affected:

```bash
ansible-playbook install-nginx.yml --list-hosts
```

This does not execute the tasks.

---

## 5.6 List Tasks

See the tasks without running them:

```bash
ansible-playbook install-nginx.yml --list-tasks
```

Useful for reviewing a playbook before execution.

---

# Task 6 — Multiple Plays in One Playbook

A single playbook can contain multiple plays.

Example:

```yaml
---
- name: Configure web servers
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: true

- name: Configure app servers
  hosts: app
  become: true

  tasks:
    - name: Install Node.js dependencies
      yum:
        name:
          - gcc
          - make
        state: present

    - name: Create app directory
      file:
        path: /opt/app
        state: directory
        mode: '0755'

- name: Configure database servers
  hosts: db
  become: true

  tasks:
    - name: Install MySQL client
      yum:
        name: mysql
        state: present

    - name: Create data directory
      file:
        path: /var/lib/appdata
        state: directory
        mode: '0700'
```

Run:

```bash
ansible-playbook multi-play.yml
```

## How it works

```text
multi-play.yml
      |
      ├── Play 1 → web
      │     └── Install + start Nginx
      |
      ├── Play 2 → app
      │     └── Install dependencies + create app directory
      |
      └── Play 3 → db
            └── Install MySQL client + create data directory
```

Each play targets its own inventory group.

### Important

If your inventory doesn't contain a group:

```ini
[db]
```

then:

```yaml
hosts: db
```

will match no hosts and that play will be skipped.

---

# Quick Module Cheat Sheet

| Module | Purpose | Example |
|---|---|---|
| `apt` | Manage Debian/Ubuntu packages | `apt: name=nginx state=present` |
| `yum` | Manage RPM-based packages | `yum: name=nginx state=present` |
| `dnf` | Modern RPM package manager | `dnf: name=nginx state=present` |
| `service` | Manage services | Start/restart Nginx |
| `copy` | Copy files | Config files |
| `file` | Manage files/directories | Create `/opt/app` |
| `command` | Run simple commands | `df -h` |
| `shell` | Run shell commands | `ps aux \| wc -l` |
| `lineinfile` | Manage one line | Add environment variable |
| `debug` | Display variables/output | Print registered results |

---

# Important Ansible Concepts

## 1. Idempotency

Ansible should only make changes when necessary.

```text
First run  → changed
Second run → ok
```

---

## 2. Desired State

You describe **what the server should look like**, rather than manually listing every command.

Example:

```yaml
state: present
```

means:

> Nginx should be installed.

```yaml
state: started
```

means:

> Nginx should be running.

---

## 3. `register`

Stores output from a task:

```yaml
register: disk_output
```

Use the result later:

```yaml
debug:
  var: disk_output.stdout_lines
```

---

## 4. Handlers

Handlers run only when notified:

```yaml
notify: Restart Nginx
```

This prevents unnecessary restarts.

---

## 5. Multiple Plays

One playbook can manage multiple server roles:

```text
web
app
db
```

Each play can target a different group.

---

# Useful Commands

### Run a playbook

```bash
ansible-playbook playbook.yml
```

### Syntax check

```bash
ansible-playbook playbook.yml --syntax-check
```

### Dry run

```bash
ansible-playbook playbook.yml --check
```

### Check + diff

```bash
ansible-playbook playbook.yml --check --diff
```

### Verbose

```bash
ansible-playbook playbook.yml -v
```

### Very verbose

```bash
ansible-playbook playbook.yml -vvv
```

### Limit hosts

```bash
ansible-playbook playbook.yml --limit web-server
```

### List hosts

```bash
ansible-playbook playbook.yml --list-hosts
```

### List tasks

```bash
ansible-playbook playbook.yml --list-tasks
```

---

# Day 69 — Final Summary

Today you learned how to move from quick Ansible commands to reusable automation.

```text
Ad-hoc commands
       ↓
   Playbooks
       ↓
     Plays
       ↓
     Tasks
       ↓
    Modules
       ↓
 Desired State
       ↓
 Idempotent Automation
```

### Most important things to remember

1. **Playbook** = YAML automation file.
2. **Play** = Defines hosts and tasks.
3. **Task** = One unit of work.
4. **Module** = Performs the actual operation.
5. **Handler** = Runs only when notified.
6. **Idempotency** = No unnecessary changes.
7. **`register`** = Stores task output.
8. **`--check`** = Preview changes.
9. **`--diff`** = Show configuration differences.
10. **Multiple plays** = Manage web, app, and database servers in one playbook.

## Day 69 Checklist

- [ ] Created first Nginx playbook
- [ ] Understood playbook structure
- [ ] Practiced `apt` / `yum`
- [ ] Practiced `service`
- [ ] Practiced `copy`
- [ ] Practiced `file`
- [ ] Practiced `command`
- [ ] Practiced `shell`
- [ ] Practiced `lineinfile`
- [ ] Used `register` and `debug`
- [ ] Created and used handlers
- [ ] Tested `--check`
- [ ] Tested `--diff`
- [ ] Tested verbosity levels
- [ ] Used `--limit`
- [ ] Used `--list-hosts`
- [ ] Used `--list-tasks`
- [ ] Created a multi-play playbook
- [ ] Verified idempotency

---

## Key Takeaway

> **Ansible playbooks let you describe the desired state of your infrastructure in YAML and apply it consistently across many servers.**

Once you understand **plays → tasks → modules → handlers**, you have the foundation needed to build real Ansible automation.

