# Day 71 — Roles, Galaxy, Templates and Vault

## Overview

As Ansible playbooks become larger, keeping all tasks, variables, handlers, templates, and files in one YAML file becomes difficult.

In this task, I learned four important Ansible features:

- **Roles** — Organize and reuse Ansible automation.
- **Jinja2 Templates** — Create dynamic configuration files.
- **Ansible Galaxy** — Download and reuse community roles.
- **Ansible Vault** — Encrypt passwords, API keys, and other secrets.

The main goal was to move from simple playbooks to a more organized and reusable Ansible project.

---

# Task 1: Jinja2 Templates

## What I did

I created a Jinja2 template called `nginx-vhost.conf.j2`.

Instead of writing fixed values directly into the Nginx configuration, I used Ansible variables and facts such as:

- `http_port`
- `app_name`
- `ansible_hostname`

Example:

```jinja2
server {
    listen {{ http_port | default(80) }};
    server_name {{ ansible_hostname }};

    root /var/www/{{ app_name }};
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/{{ app_name }}_access.log;
    error_log /var/log/nginx/{{ app_name }}_error.log;
}
```

I then created `template-demo.yml` to:

1. Install Nginx.
2. Create the application web directory.
3. Render the Jinja2 template.
4. Create a dynamic `index.html`.
5. Restart Nginx when the configuration changes.

I ran:

```bash
ansible-playbook template-demo.yml --diff
```

The `--diff` option helped me see what configuration Ansible was going to change.

## What I learned

A Jinja2 template allows me to create **dynamic configuration files**.

For example:

```text
{{ app_name }}
```

is replaced with the actual value of `app_name`.

Ansible facts such as:

```text
{{ ansible_hostname }}
{{ ansible_default_ipv4.address }}
```

can also be used to automatically insert information about the target server.

### Key point

**Template = Static file + Variables/Facts → Dynamic configuration**

---

# Task 2: Understand the Role Structure

## What I did

I learned how an Ansible Role organizes automation into separate directories.

I generated a role skeleton using:

```bash
ansible-galaxy init roles/webserver
```

This created the standard role structure:

```text
roles/
└── webserver/
    ├── tasks/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── templates/
    ├── files/
    ├── vars/
    │   └── main.yml
    ├── defaults/
    │   └── main.yml
    ├── meta/
    │   └── main.yml
    └── README.md
```

## Purpose of each directory

| Directory | Purpose |
|---|---|
| `tasks/` | Main tasks executed by the role |
| `handlers/` | Handlers such as restarting services |
| `templates/` | Jinja2 template files |
| `files/` | Static files copied to servers |
| `vars/` | Role variables with high priority |
| `defaults/` | Default variables that are easy to override |
| `meta/` | Role metadata and dependencies |
| `README.md` | Documentation for the role |

## `vars` vs `defaults`

### `defaults/main.yml`

Contains default values.

These variables are designed to be easily overridden.

Example:

```yaml
http_port: 80
app_name: myapp
```

### `vars/main.yml`

Contains role variables with higher variable precedence.

These values are generally used when the role needs more fixed or strongly controlled values.

### Simple way to remember

```text
defaults → flexible defaults
vars     → higher-priority role variables
```

---

# Task 3: Build a Custom Webserver Role

## What I did

I created my own `webserver` role instead of putting all Nginx tasks directly inside a playbook.

My role contains:

```text
roles/webserver/
├── defaults/
│   └── main.yml
├── tasks/
│   └── main.yml
├── handlers/
│   └── main.yml
└── templates/
    ├── nginx.conf.j2
    ├── vhost.conf.j2
    └── index.html.j2
```

## Step 1: Define default variables

In `defaults/main.yml`, I defined:

```yaml
---
http_port: 80
app_name: myapp
max_connections: 512
```

This makes the role reusable because the values can be changed from the playbook.

## Step 2: Create the tasks

In `tasks/main.yml`, I created tasks to:

1. Install Nginx.
2. Deploy the main Nginx configuration.
3. Deploy the virtual host configuration.
4. Create the application web root.
5. Deploy the HTML page.
6. Start and enable Nginx.

The role handles the complete web-server setup.

## Step 3: Create a handler

In `handlers/main.yml`, I created a handler to restart Nginx:

```yaml
---
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

The handler runs when a configuration template changes.

## Step 4: Create a dynamic HTML template

I created `index.html.j2`:

```jinja2
<h1>{{ app_name }}</h1>
<p>Server: {{ ansible_hostname }}</p>
<p>IP: {{ ansible_default_ipv4.address }}</p>
<p>Environment: {{ app_env | default('development') }}</p>
<p>Managed by Ansible</p>
```

This allows the webpage to show information about the server automatically.

## Step 5: Use the role from a playbook

I created `site.yml`:

```yaml
---
- name: Configure web servers
  hosts: web
  become: true
  roles:
    - role: webserver
      vars:
        app_name: terraweek
        http_port: 80
```

Then I ran:

```bash
ansible-playbook site.yml
```

Finally, I verified the result by accessing the web server with `curl`.

## What I learned

Roles make Ansible projects:

- Easier to organize.
- Easier to reuse.
- Easier to maintain.
- Easier to share.
- Easier to scale.

### Key point

Instead of writing:

```text
One huge playbook
        ↓
Many tasks
        ↓
Hard to maintain
```

I can use:

```text
Role
├── Tasks
├── Handlers
├── Templates
├── Variables
└── Files
```

---

# Task 4: Ansible Galaxy — Use Community Roles

## What I did

I learned that **Ansible Galaxy** provides community-created roles that can be reused instead of building everything from scratch.

## Step 1: Search for roles

I used:

```bash
ansible-galaxy search nginx --platforms EL
ansible-galaxy search mysql
```

This helped me find available roles.

## Step 2: Install a role

I installed the Docker role:

```bash
ansible-galaxy install geerlingguy.docker
```

## Step 3: Check installed roles

I used:

```bash
ansible-galaxy list
```

This showed the roles installed on my system.

## Step 4: Use the Galaxy role

I created `docker-setup.yml`:

```yaml
---
- name: Install Docker using Galaxy role
  hosts: app
  become: true
  roles:
    - geerlingguy.docker
```

Instead of writing many Docker installation tasks myself, I could use the community role with one role entry.

## Step 5: Use `requirements.yml`

I created:

```yaml
---
roles:
  - name: geerlingguy.docker
    version: "7.4.1"
  - name: geerlingguy.ntp
```

Then installed all required roles with:

```bash
ansible-galaxy install -r requirements.yml
```

## Why use `requirements.yml`?

A requirements file is better than installing roles manually because it:

- Keeps dependencies in one place.
- Makes the project reproducible.
- Allows role versions to be specified.
- Makes setup easier for other team members.
- Works well in CI/CD pipelines.

### Key point

```text
requirements.yml
       ↓
Install all required roles
       ↓
Consistent project setup
```

---

# Task 5: Ansible Vault — Encrypt Secrets

## What I did

I learned how to protect sensitive information using **Ansible Vault**.

Passwords, API keys, and tokens should not be stored as plain text in a Git repository.

## Step 1: Create an encrypted file

I created:

```bash
ansible-vault create group_vars/db/vault.yml
```

Ansible asked for a Vault password and opened an editor.

I added variables such as:

```yaml
vault_db_password: SuperSecretP@ssw0rd
vault_db_root_password: R00tP@ssw0rd123
vault_api_key: sk-abc123xyz789
```

After saving the file, its contents were encrypted.

## Step 2: Edit the encrypted file

I used:

```bash
ansible-vault edit group_vars/db/vault.yml
```

This allows me to modify the encrypted data without manually decrypting the file.

## Step 3: View the encrypted file

I used:

```bash
ansible-vault view group_vars/db/vault.yml
```

This displays the decrypted content temporarily.

## Step 4: Encrypt an existing file

I used:

```bash
ansible-vault encrypt group_vars/db/secrets.yml
```

This encrypts an existing plain-text file.

## Step 5: Use Vault variables

I created `db-setup.yml` and referenced the Vault variable:

```yaml
---
- name: Configure database
  hosts: db
  become: true

  tasks:
    - name: Show DB password status
      debug:
        msg: "DB password is set: {{ vault_db_password | length > 0 }}"
```

I ran the playbook with:

```bash
ansible-playbook db-setup.yml --ask-vault-pass
```

Ansible asked for the Vault password before running the playbook.

## Step 6: Use a Vault password file

For automation, I created a password file:

```bash
echo "YourVaultPassword" > .vault_pass
chmod 600 .vault_pass
echo ".vault_pass" >> .gitignore
```

Then I ran:

```bash
ansible-playbook db-setup.yml --vault-password-file .vault_pass
```

I could also configure it in `ansible.cfg`:

```ini
[defaults]
vault_password_file = .vault_pass
```

## Why use `--vault-password-file` in CI/CD?

`--ask-vault-pass` requires interactive input, which is not suitable for automated pipelines.

A password file allows the pipeline to provide the Vault password automatically.

However, the password file itself must be protected and should never be committed to Git.

### Key point

```text
Sensitive data
      ↓
Ansible Vault
      ↓
Encrypted file
      ↓
Safe to store with the project
```

---

# Task 6: Combine Roles, Templates, and Vault

## What I did

In the final task, I combined everything I learned into one Ansible project.

The project uses:

- A custom `webserver` role.
- A Galaxy Docker role.
- Jinja2 templates.
- Ansible Vault variables.
- Different host groups for different server types.

## Web servers

For web servers, I used my custom `webserver` role:

```yaml
- name: Configure web servers
  hosts: web
  become: true
  roles:
    - role: webserver
      vars:
        app_name: terraweek
        http_port: 80
```

## App servers

For application servers, I used the Galaxy Docker role:

```yaml
- name: Configure app servers with Docker
  hosts: app
  become: true
  roles:
    - geerlingguy.docker
```

## Database servers

For database servers, I used a Jinja2 template to create a configuration file:

```yaml
- name: Configure database servers
  hosts: db
  become: true
  tasks:
    - name: Create DB config with secrets
      template:
        src: templates/db-config.j2
        dest: /etc/db-config.env
        owner: root
        mode: '0600'
```

## Database template

I created `templates/db-config.j2`:

```jinja2
# Database Configuration -- Managed by Ansible
DB_HOST={{ ansible_default_ipv4.address }}
DB_PORT={{ db_port | default(3306) }}
DB_PASSWORD={{ vault_db_password }}
DB_ROOT_PASSWORD={{ vault_db_root_password }}
```

Here, Ansible combines:

- Server facts.
- Normal variables.
- Vault-encrypted secrets.

The final configuration file is generated automatically on the database server.

## File permissions

I used:

```yaml
mode: '0600'
```

This means the configuration file can only be read and written by its owner.

This is important because the file contains database passwords.

## Run the complete project

I ran:

```bash
ansible-playbook site.yml
```

Then I verified the database server:

```bash
cat /etc/db-config.env
```

I checked that:

- The variables were rendered correctly.
- The secrets were inserted.
- The configuration file existed.
- The file permissions were `600`.

---

# Important Commands

## Roles

```bash
ansible-galaxy init roles/webserver
ansible-galaxy list
```

## Galaxy

```bash
ansible-galaxy search nginx
ansible-galaxy install geerlingguy.docker
ansible-galaxy install -r requirements.yml
```

## Templates

```bash
ansible-playbook template-demo.yml --diff
```

## Vault

```bash
ansible-vault create secrets.yml
ansible-vault edit secrets.yml
ansible-vault view secrets.yml
ansible-vault encrypt secrets.yml
ansible-playbook db-setup.yml --ask-vault-pass
ansible-playbook db-setup.yml --vault-password-file .vault_pass
```

---

# What I Learned Today

| Topic | What I learned |
|---|---|
| **Jinja2 Templates** | Create dynamic configuration files |
| **Roles** | Organize automation into reusable components |
| **Defaults** | Store easily overridable role defaults |
| **Vars** | Store higher-priority role variables |
| **Handlers** | Run actions such as restarting services when notified |
| **Ansible Galaxy** | Find and reuse community roles |
| **requirements.yml** | Manage role dependencies and versions |
| **Ansible Vault** | Encrypt sensitive information |
| **Vault Password File** | Provide Vault credentials to automated processes |
| **Facts** | Use information collected from target servers |
| **Role Variables** | Customize reusable roles |

---

# Final Project Flow

```text
                    Ansible
                       |
        +--------------+--------------+
        |              |              |
      Roles         Templates       Vault
        |              |              |
   Reusable       Dynamic Config   Encrypted
   Automation         Files          Secrets
        |              |              |
        +--------------+--------------+
                       |
                 Galaxy Roles
                       |
                       ↓
              Complete Automation
```

---

# Key Takeaways

1. **Roles** are the standard way to organize larger Ansible projects.
2. **Jinja2 templates** make configuration files dynamic.
3. **Ansible Galaxy** lets me reuse community-created roles.
4. **`requirements.yml`** makes role dependencies easier to manage and reproduce.
5. **Ansible Vault** protects passwords, API keys, and other sensitive data.
6. **Handlers** are useful for restarting or reloading services only when required.
7. **Facts** allow templates to use information collected from target machines.
8. Combining **Roles + Templates + Galaxy + Vault** makes Ansible automation more scalable and production-friendly.

## One-line Summary

> **Roles organize automation, Templates make it dynamic, Galaxy makes it reusable, and Vault keeps secrets safe.**

