# Day 70 -- Variables, Facts, Conditionals and Loops

## Overview

In earlier Ansible playbooks, the tasks were mostly static. The same task ran with the same values on every server.

In this task, I learned how to make Ansible playbooks more flexible and dynamic using:

- **Variables** - store values that can change.
- **Facts** - collect information automatically from managed servers.
- **Conditionals** - run tasks only when a condition is true.
- **Loops** - repeat a task for multiple items.
- **Register** - save the output of a task and use it later.

These features help Ansible adapt its behavior based on the host, group, operating system, memory, environment, and other server information.

---

# Task 1: Variables in Playbooks

### What I did

I created `variables-demo.yml` and defined variables inside the playbook.

The variables included:

- `app_name` - application name
- `app_port` - application port
- `app_dir` - application directory
- `packages` - list of packages to install

I used Jinja2 syntax such as `{{ app_name }}` to use the variable values inside tasks.

### Main tasks performed

1. Printed the application details using the `debug` module.
2. Created the application directory using the `file` module.
3. Installed Git, Curl, and Wget using the `yum` module.
4. Ran the playbook to check whether the variables were resolved correctly.
5. Overrode variables from the command line using `-e`.

### Command

```bash
ansible-playbook variables-demo.yml -e "app_name=my-custom-app app_port=9090"
```

### What I learned

Variables prevent hardcoding values in playbooks.

For example:

```yaml
app_dir: "/opt/{{ app_name }}"
```

If `app_name` changes, `app_dir` automatically changes as well.

### Important point

Extra variables passed using `-e` have very high precedence and can override variables defined in the playbook.

---

# Task 2: group_vars and host_vars

### What I did

Instead of keeping all variables inside the playbook, I moved them into separate variable files.

I created this structure:

```text
ansible-practice/
├── inventory.ini
├── ansible.cfg
├── group_vars/
│   ├── all.yml
│   ├── web.yml
│   └── db.yml
├── host_vars/
│   └── web-server.yml
└── playbooks/
    └── site.yml
```

### `group_vars/all.yml`

These variables apply to all hosts.

```yaml
ntp_server: pool.ntp.org
app_env: development
common_packages:
  - vim
  - htop
  - tree
```

### `group_vars/web.yml`

These variables apply only to hosts in the `web` group.

```yaml
http_port: 80
max_connections: 1000
web_packages:
  - nginx
```

### `group_vars/db.yml`

These variables apply only to hosts in the `db` group.

```yaml
db_port: 3306
db_packages:
  - mysql-server
```

### `host_vars/web-server.yml`

These variables apply only to the specific `web-server` host.

```yaml
max_connections: 2000
custom_message: "This is the primary web server"
```

### What I did in `site.yml`

I created two plays:

1. **Apply common configuration**
   - Runs on all hosts.
   - Installs common packages.
   - Displays the environment.

2. **Configure web servers**
   - Runs only on the `web` group.
   - Displays web-specific variables.
   - Displays the host-specific message.

### What I learned

Ansible automatically loads variables from `group_vars` and `host_vars` based on the inventory structure.

A simplified precedence example is:

```text
Playbook vars
     ↓
group_vars
     ↓
host_vars
     ↓
-e extra variables
```

For the scenario in this task:

**host_vars > group_vars > playbook vars**

and:

**`-e` extra variables override everything else.**

---

# Task 3: Ansible Facts

### What I did

I learned that Ansible automatically gathers information about managed servers. These pieces of information are called **facts**.

Facts can contain information about:

- Operating system
- Hostname
- IP address
- RAM
- CPU
- Network interfaces
- Disks
- Kernel
- Architecture
- And many other system details

### See all facts

```bash
ansible web-server -m setup
```

The `setup` module collects and displays Ansible facts.

### Filter specific facts

I used filters to display only the information I needed.

```bash
ansible web-server -m setup -a "filter=ansible_os_family"
```

```bash
ansible web-server -m setup -a "filter=ansible_distribution*"
```

```bash
ansible web-server -m setup -a "filter=ansible_memtotal_mb"
```

```bash
ansible web-server -m setup -a "filter=ansible_default_ipv4"
```

### Facts playbook

I created `facts-demo.yml`.

The playbook displayed:

- Hostname
- Operating system
- OS version
- RAM
- IP address
- Network interfaces

Example:

```yaml
msg: >
  Hostname: {{ ansible_hostname }},
  OS: {{ ansible_distribution }} {{ ansible_distribution_version }},
  RAM: {{ ansible_memtotal_mb }}MB,
  IP: {{ ansible_default_ipv4.address }}
```

### Five useful facts

| Fact | Why it is useful |
|---|---|
| `ansible_hostname` | Identify the current server |
| `ansible_distribution` | Run OS-specific tasks |
| `ansible_distribution_version` | Handle different OS versions |
| `ansible_memtotal_mb` | Make decisions based on available memory |
| `ansible_default_ipv4.address` | Get the server's primary IP address |

### What I learned

Facts make playbooks intelligent because Ansible can make decisions based on the actual server information.

---

# Task 4: Conditionals with `when`

### What I did

I created `conditional-demo.yml` and used the `when` keyword to control whether a task should run.

Instead of running every task on every server, Ansible checks a condition first.

### Examples

Install Nginx only on web servers:

```yaml
when: "'web' in group_names"
```

Install MySQL only on database servers:

```yaml
when: "'db' in group_names"
```

Show a warning when RAM is less than 1 GB:

```yaml
when: ansible_memtotal_mb < 1024
```

Run only on Amazon Linux:

```yaml
when: ansible_distribution == "Amazon"
```

Run only on Ubuntu:

```yaml
when: ansible_distribution == "Ubuntu"
```

Run only in production:

```yaml
when: app_env == "production"
```

### Multiple conditions

For an AND condition, I used a list:

```yaml
when:
  - "'web' in group_names"
  - ansible_memtotal_mb >= 512
```

Both conditions must be true.

### OR condition

```yaml
when: "'web' in group_names or 'app' in group_names"
```

At least one condition must be true.

### What I observed

When a condition was false, Ansible skipped that task instead of executing it.

Example:

```text
skipping: [db-server]
```

### What I learned

`when` is useful when different servers need different configurations.

It helps avoid creating separate playbooks for every server type.

---

# Task 5: Loops

### What I did

I created `loops-demo.yml` to learn how to repeat the same task for multiple items.

I defined two variables:

```yaml
users:
  - name: deploy
    groups: wheel
  - name: monitor
    groups: wheel
  - name: appuser
    groups: users
```

and:

```yaml
directories:
  - /opt/app/logs
  - /opt/app/config
  - /opt/app/data
  - /opt/app/tmp
```

### Tasks performed

#### 1. Created multiple users

```yaml
loop: "{{ users }}"
```

The same `user` task ran once for each user.

#### 2. Created multiple directories

```yaml
loop: "{{ directories }}"
```

This created all required application directories.

#### 3. Installed multiple packages

```yaml
loop:
  - git
  - curl
  - unzip
  - jq
```

This installed each package one by one.

#### 4. Printed each created user

```yaml
loop: "{{ users }}"
```

The `debug` task displayed information about every user.

### What I observed

Ansible showed each loop iteration separately in the output.

For example:

```text
changed: [server] => (item=git)
changed: [server] => (item=curl)
changed: [server] => (item=unzip)
```

### `loop` vs `with_items`

`with_items` is the older looping syntax.

`loop` is the modern and recommended syntax for most Ansible loops.

Example:

```yaml
loop:
  - git
  - curl
  - wget
```

### What I learned

Loops reduce duplicate code.

Instead of writing the same task several times, I can write it once and provide a list of items.

---

# Task 6: Register, Debug, and Combine Everything

### What I did

I created `server-report.yml` as a real-world server health report.

This playbook combines:

- Variables
- Ansible facts
- `register`
- `debug`
- Conditionals
- Commands
- File creation

### 1. Checked disk space

```yaml
command: df -h /
register: disk_result
```

The command output was saved in `disk_result`.

### 2. Checked memory

```yaml
command: free -m
register: memory_result
```

The result was stored in `memory_result`.

### 3. Checked running services

```yaml
shell: systemctl list-units --type=service --state=running | head -20
register: services_result
```

The output was stored in `services_result`.

### 4. Generated a server report

I used `debug` to display information such as:

- Hostname
- Operating system
- IP address
- RAM
- Disk usage
- Number of running services

Example:

```yaml
"OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"
"IP: {{ ansible_default_ipv4.address }}"
"RAM: {{ ansible_memtotal_mb }}MB"
```

### 5. Checked for low disk space

I added a conditional task that displays an alert if the disk usage indicates that the filesystem is critically full.

```yaml
when: "'9[0-9]%' in disk_result.stdout or '100%' in disk_result.stdout"
```

### 6. Saved the report to a file

I used the `copy` module to create:

```text
/tmp/server-report-<hostname>.txt
```

The report contains:

- Server name
- OS
- IP
- RAM
- Disk information
- Timestamp

### Verify the report

After running the playbook, I can SSH into a server and check:

```bash
cat /tmp/server-report-*.txt
```

This verifies that the report file was created and contains the expected information.

### What I learned about `register`

`register` stores the result of a task in a variable.

For example:

```yaml
register: disk_result
```

Later, I can access information from that result:

```yaml
{{ disk_result.stdout }}
```

or:

```yaml
{{ disk_result.stdout_lines }}
```

This allows one task to collect information and another task to use that information.

---

# Key Concepts Learned

## Variables

Variables store values that can be reused throughout a playbook.

```yaml
app_name: myapp
app_port: 8080
```

Use them with:

```yaml
{{ app_name }}
{{ app_port }}
```

## Facts

Facts are automatically collected information about managed servers.

```yaml
{{ ansible_distribution }}
{{ ansible_memtotal_mb }}
{{ ansible_default_ipv4.address }}
```

## Conditionals

Conditionals control whether a task should run.

```yaml
when: ansible_distribution == "Ubuntu"
```

## Loops

Loops repeat a task for multiple items.

```yaml
loop:
  - git
  - curl
  - wget
```

## Register

`register` saves the result of a task.

```yaml
register: result
```

The result can then be used later:

```yaml
{{ result.stdout }}
```

---

# Day 70 Workflow

```text
                Ansible Playbook
                       |
          +------------+------------+
          |            |            |
       Variables     Facts      Inventory
          |            |            |
          +------------+------------+
                       |
                 Make decisions
                       |
                 Conditionals
                    /      \
                  Yes       No
                   |         |
                 Run       Skip
                   |
                 Loops
                   |
             Repeat tasks
                   |
                Register
                   |
             Save results
                   |
                 Debug
                   |
              Final Report
```

---

# Important Commands

### Run a playbook

```bash
ansible-playbook variables-demo.yml
```

### Override variables

```bash
ansible-playbook variables-demo.yml -e "app_name=my-custom-app app_port=9090"
```

### View all facts

```bash
ansible web-server -m setup
```

### View a specific fact

```bash
ansible web-server -m setup -a "filter=ansible_os_family"
```

### Check memory fact

```bash
ansible web-server -m setup -a "filter=ansible_memtotal_mb"
```

---

# Final Takeaways

- **Variables** make playbooks reusable and configurable.
- **group_vars** allow variables to be shared by a group of hosts.
- **host_vars** allow variables to be customized for a specific host.
- **Facts** provide information about the managed server.
- **`when`** allows tasks to run only when required.
- **Loops** prevent repetitive task definitions.
- **`register`** stores task results for later use.
- **Debugging** helps verify variables, facts, and command results.
- Combining these features turns a static playbook into **dynamic and intelligent automation**.

## Day 70 Summary

The main goal of Day 70 was to move from static Ansible automation to dynamic automation.

Instead of saying:

> "Run exactly these commands on every server."

I learned to build playbooks that can say:

> "Check the server, understand its environment, choose the correct configuration, repeat tasks when needed, and use the results to make further decisions."

This is an important step toward writing real-world Ansible automation.

