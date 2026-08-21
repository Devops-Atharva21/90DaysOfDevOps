# Day 68 — Introduction to Ansible and Inventory Setup

## What is Ansible?

**Ansible** is a configuration management and automation tool.

Terraform is mainly used to **create infrastructure**.  
Ansible is used after that to **configure and manage servers**.

### What can Ansible do?

- Install packages
- Configure services
- Create and manage users
- Copy files
- Start/stop services
- Run commands
- Keep servers in the desired state

### Key Point

> **Ansible is agentless.**  
> Ansible does not need an agent installed on the target servers. It mainly uses **SSH** to connect to Linux servers.

---

## Expected Output

By the end of this task:

- Ansible is installed on the **control node**
- 2–3 EC2 instances are running as **managed nodes**
- An inventory file is created with groups
- Ad-hoc commands work successfully
- `day-68-ansible-intro.md` is created

---

# Task 1 — Understand Ansible

## What is Configuration Management?

Configuration management means **automating and maintaining the configuration of servers**.

Without configuration management, we may have to manually:

- Install packages
- Create users
- Configure services
- Change files
- Fix server settings

This becomes difficult when there are many servers.

### Why do we need it?

- Reduces manual work
- Makes configuration consistent
- Reduces human errors
- Makes changes repeatable
- Helps manage many servers

---

## Ansible vs Chef vs Puppet vs Salt

| Tool | Agent | Main Idea |
|---|---|---|
| **Ansible** | Agentless | Uses SSH and is simple to start |
| **Chef** | Agent-based | Uses Ruby and a client-server model |
| **Puppet** | Agent-based | Uses Puppet agents and manifests |
| **Salt** | Usually agent-based | Uses Salt minions/master |

### Why Ansible is popular

- Agentless
- Uses SSH
- YAML is easy to read
- Simple to learn
- Good for automation and configuration management

---

## What does Agentless mean?

**Agentless** means that we do not need to install Ansible software/agent on every managed server.

Example:

```text
Control Node
    |
    | SSH
    v
+-----------+    +-----------+    +-----------+
| Web Server|    | App Server|    | DB Server |
+-----------+    +-----------+    +-----------+
```

Ansible runs from the **control node** and connects to the managed nodes.

---

## Ansible Architecture

```text
                    ANSIBLE
                       |
                +------+------+
                |             |
          Control Node     Inventory
          (runs Ansible)   (hosts/groups)
                |
               SSH
                |
        +-------+-------+
        |       |       |
       Web     App      DB
      Server  Server   Server
```

### Important Components

**1. Control Node**

The machine where Ansible is installed and executed.

Examples:

- Your laptop
- A jump server
- A dedicated management EC2 instance

**2. Managed Nodes**

The servers that Ansible manages.

Example:

- Web server
- App server
- Database server

**3. Inventory**

A list of servers that Ansible manages.

It can also organize servers into groups.

**4. Modules**

Modules perform specific actions.

Examples:

- `command` → run commands
- `copy` → copy files
- `yum` / `apt` → manage packages
- `service` → manage services
- `user` → manage users
- `ping` → test connectivity

**5. Playbooks**

YAML files that describe **what Ansible should do and on which hosts**.

---

# Task 2 — Set Up the Lab Environment

You need **2–3 EC2 instances**.

## Option A — Terraform

Recommended because Terraform can create the infrastructure for you.

Use:

- Amazon Linux 2 or Ubuntu 22.04
- `t2.micro`
- Security group allowing SSH on port `22`
- EC2 key pair

## Option B — AWS Console

Create the EC2 instances manually with the same settings.

### Lab Servers

```text
Instance 1 → Web Server
Instance 2 → App Server
Instance 3 → DB Server
```

---

## Test SSH Access

From your control node:

```bash
ssh -i ~/your-key.pem ec2-user@<public-ip-1>
ssh -i ~/your-key.pem ec2-user@<public-ip-2>
ssh -i ~/your-key.pem ec2-user@<public-ip-3>
```

For Ubuntu, the username is usually:

```bash
ubuntu
```

### Important

Before using Ansible, make sure normal SSH access works.

---

# Task 3 — Install Ansible

Install Ansible on the **control node**.

You do **not** normally install Ansible on every managed node.

## macOS

```bash
brew install ansible
```

## Ubuntu / Debian

```bash
sudo apt update
sudo apt install ansible -y
```

## Amazon Linux / RHEL

```bash
sudo yum install ansible -y
```

Or:

```bash
pip3 install ansible
```

## Verify Installation

```bash
ansible --version
```

The output should show information such as:

- Ansible version
- Config file path
- Python version

### Why only the control node?

Ansible runs from the control node and connects to managed nodes remotely.

```text
Ansible installed here
        |
        | SSH
        v
Managed servers
(no Ansible agent required)
```

---

# Task 4 — Create the Inventory

The **inventory** tells Ansible:

> "These are the servers I want to manage."

Create a project directory:

```bash
mkdir ansible-practice
cd ansible-practice
```

Create:

```text
inventory.ini
```

## Basic Inventory

```ini
[web]
web-server ansible_host=<PUBLIC_IP_1>

[app]
app-server ansible_host=<PUBLIC_IP_2>

[db]
db-server ansible_host=<PUBLIC_IP_3>

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/your-key.pem
```

### Inventory Structure

```text
all
├── web
│   └── web-server
├── app
│   └── app-server
└── db
    └── db-server
```

Groups make it easy to target specific servers.

---

## Test Connectivity

```bash
ansible all -i inventory.ini -m ping
```

Expected result:

```text
SUCCESS
"ping": "pong"
```

You should get a successful response from each server.

### Important

Ansible's `ping` module is **not the same as the normal network ping command**.

It checks whether Ansible can connect to the host and execute its module successfully.

---

## Troubleshooting

If `ansible ping` fails, check:

### 1. SSH key permissions

```bash
chmod 400 your-key.pem
```

### 2. Security Group

Make sure the EC2 security group allows:

```text
SSH → TCP → Port 22 → Your IP
```

### 3. Correct username

Amazon Linux:

```ini
ansible_user=ec2-user
```

Ubuntu:

```ini
ansible_user=ubuntu
```

### 4. Correct private key

Check:

```ini
ansible_ssh_private_key_file=~/your-key.pem
```

---

# Task 5 — Run Ad-Hoc Commands

## What are Ad-Hoc Commands?

Ad-hoc commands are **quick, one-time Ansible commands**.

You use them when you want to perform a simple task without creating a playbook.

General syntax:

```bash
ansible <host-pattern> -i <inventory> -m <module> -a "<arguments>"
```

Where:

- `ansible` → Ansible command
- `<host-pattern>` → which hosts to target
- `-i` → inventory file
- `-m` → module
- `-a` → module arguments

---

## 1. Check Uptime

Run on all servers:

```bash
ansible all -i inventory.ini -m command -a "uptime"
```

---

## 2. Check Free Memory

Run only on the `web` group:

```bash
ansible web -i inventory.ini -m command -a "free -h"
```

Notice:

```text
all → every server
web → only web servers
```

---

## 3. Check Disk Space

```bash
ansible all -i inventory.ini -m command -a "df -h"
```

---

## 4. Install a Package

For Amazon Linux / RHEL:

```bash
ansible web -i inventory.ini -m yum -a "name=git state=present" --become
```

For Ubuntu:

```bash
ansible web -i inventory.ini -m apt -a "name=git state=present" --become
```

### What is `--become`?

`--become` tells Ansible to **escalate privileges**, usually using `sudo`.

You need it when the task requires administrator/root permissions.

Example:

```text
Normal user
    |
    | --become
    v
Root / sudo privileges
```

---

## 5. Copy a File

Create a local file:

```bash
echo "Hello from Ansible" > hello.txt
```

Copy it to all servers:

```bash
ansible all -i inventory.ini -m copy -a "src=hello.txt dest=/tmp/hello.txt"
```

---

## 6. Verify the File

```bash
ansible all -i inventory.ini -m command -a "cat /tmp/hello.txt"
```

Expected output:

```text
Hello from Ansible
```

---

# Task 6 — Inventory Groups and Patterns

Ansible allows us to create **groups of groups**.

## Group of Groups

Add this to `inventory.ini`:

```ini
[application:children]
web
app

[all_servers:children]
application
db
```

Now the structure becomes:

```text
all_servers
├── application
│   ├── web
│   └── app
└── db
```

---

## Run Commands Against Groups

### Web + App

```bash
ansible application -i inventory.ini -m ping
```

### Only DB

```bash
ansible db -i inventory.ini -m ping
```

### Everything

```bash
ansible all_servers -i inventory.ini -m ping
```

---

# Ansible Patterns

Patterns let you select hosts in different ways.

## OR

Run against `web` **or** `app`:

```bash
ansible 'web:app' -i inventory.ini -m ping
```

## NOT

Run against everything except `db`:

```bash
ansible 'all:!db' -i inventory.ini -m ping
```

### Pattern Cheat Sheet

```text
all         → all hosts
web         → web group
web:app     → web OR app
all:!db     → everything EXCEPT db
```

---

# Create ansible.cfg

Typing `-i inventory.ini` every time is annoying.

Create:

```text
ansible.cfg
```

Add:

```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
remote_user = ec2-user
private_key_file = ~/your-key.pem
```

Now Ansible automatically knows the inventory file.

Instead of:

```bash
ansible all -i inventory.ini -m ping
```

You can run:

```bash
ansible all -m ping
```

## Verify

```bash
ansible all -m ping
```

If you get:

```text
SUCCESS
"ping": "pong"
```

then your `ansible.cfg` is working.

---

# Quick Ansible Cheat Sheet

## Basic Command

```bash
ansible <host-pattern> -m <module> -a "<arguments>"
```

## Common Modules

| Module | Purpose |
|---|---|
| `ping` | Test Ansible connectivity |
| `command` | Run a command |
| `shell` | Run commands through a shell |
| `copy` | Copy files |
| `yum` | Manage packages on RHEL/Amazon Linux |
| `apt` | Manage packages on Ubuntu/Debian |
| `service` | Manage services |
| `user` | Manage users |

## Common Options

| Option | Meaning |
|---|---|
| `-i` | Specify inventory |
| `-m` | Select module |
| `-a` | Module arguments |
| `--become` | Use elevated privileges |
| `-v` | Verbose output |

---

# Important Concepts to Remember

```text
Terraform
   ↓
Creates infrastructure
   ↓
EC2 instances exist
   ↓
Ansible
   ↓
Configures and manages servers
```

### Ansible Flow

```text
Control Node
     |
     | SSH
     ↓
Inventory → tells Ansible WHO
     |
     ↓
Module → tells Ansible WHAT
     |
     ↓
Playbook → defines HOW
     |
     ↓
Managed Nodes
```

### Remember

- **Control Node** → where Ansible runs
- **Managed Node** → server being managed
- **Inventory** → list/groups of servers
- **Module** → performs an action
- **Playbook** → YAML automation instructions
- **Ad-hoc command** → quick one-time task
- **`--become`** → privilege escalation
- **SSH** → main connection method for Linux
- **Agentless** → no Ansible agent required on managed nodes

---

# Final Checklist

- [ ] Create 2–3 EC2 instances
- [ ] Verify SSH access
- [ ] Install Ansible on the control node
- [ ] Run `ansible --version`
- [ ] Create `inventory.ini`
- [ ] Create `web`, `app`, and `db` groups
- [ ] Run `ansible all -m ping`
- [ ] Test uptime, memory, and disk commands
- [ ] Install a package using Ansible
- [ ] Copy and verify a file
- [ ] Create group-of-groups
- [ ] Practice Ansible patterns
- [ ] Create `ansible.cfg`
- [ ] Verify `ansible all -m ping` works without `-i`

---

## Key Takeaway

> **Terraform creates the infrastructure. Ansible configures and manages it.**

The most important idea from Day 68:

> **Ansible is agentless and uses SSH to manage servers from a control node.**

