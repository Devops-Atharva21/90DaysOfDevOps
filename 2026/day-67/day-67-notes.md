# Day 67 — TerraWeek Capstone: Multi-Environment Infrastructure with Workspaces and Modules

## Overview

Day 67 brings together the Terraform concepts learned during TerraWeek:

- HCL
- Providers
- Resources
- Dependencies
- Variables
- Outputs
- Data sources
- State management
- Remote backends
- Custom modules
- Registry modules
- Terraform workspaces
- AWS infrastructure

The goal was to build **one reusable Terraform codebase** that can manage three isolated AWS environments:

**Dev → Staging → Prod**

Each environment uses its own Terraform workspace and environment-specific variable file.

---

# Task 1 — Learn Terraform Workspaces

Terraform workspaces allow the same Terraform configuration to manage multiple independent states.

### Commands used

```bash
mkdir terraweek-capstone
cd terraweek-capstone

terraform init

terraform workspace show

terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

terraform workspace list

terraform workspace select dev
terraform workspace select staging
terraform workspace select prod
```

### What I learned

`terraform.workspace` returns the name of the currently selected workspace.

Example:

```hcl
locals {
  environment = terraform.workspace
}
```

If the active workspace is `dev`:

```text
terraform.workspace = "dev"
```

If the active workspace is `prod`:

```text
terraform.workspace = "prod"
```

### Where is workspace state stored?

With the default local backend, each workspace has its own state. The exact storage layout depends on the backend.

With an S3 backend, workspace states are separated using workspace-specific state paths.

The important idea is:

```text
One Terraform configuration
        |
        +---- dev state
        |
        +---- staging state
        |
        +---- prod state
```

### Workspaces vs separate directories

| Workspaces | Separate directories |
|---|---|
| Same Terraform code | Each directory has its own configuration |
| Separate state per workspace | Separate state per directory |
| Easy for similar environments | More flexibility between environments |
| Uses `terraform.workspace` | Environment is represented by directory/config |
| Less code duplication | Can have more configuration duplication |

For this capstone, workspaces were used to practice managing similar environments from one codebase.

---

# Task 2 — Project Structure

The project was organized into a root module and three reusable child modules.

```text
terraweek-capstone/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── locals.tf
├── dev.tfvars
├── staging.tfvars
├── prod.tfvars
├── .gitignore
│
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security-group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── ec2-instance/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Purpose of the files

### Root files

- `providers.tf` → AWS provider and backend configuration
- `main.tf` → calls the custom modules
- `variables.tf` → defines root input variables
- `outputs.tf` → exposes useful infrastructure outputs
- `locals.tf` → creates workspace-aware local values
- `dev.tfvars` → Dev configuration
- `staging.tfvars` → Staging configuration
- `prod.tfvars` → Production configuration
- `.gitignore` → prevents Terraform state and sensitive files from being committed

### Module files

Each module follows the same pattern:

```text
main.tf       → resources
variables.tf  → inputs
outputs.tf    → outputs
```

This keeps each module focused and reusable.

---

# Task 3 — Create `.gitignore`

The following Terraform-generated and potentially sensitive files were ignored:

```gitignore
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
```

### Why?

Terraform state can contain sensitive infrastructure information, and `.tfvars` files may contain secrets or environment-specific values.

The `.terraform/` directory contains downloaded providers and modules, so it should not be committed.

> Note: In many team repositories, `.terraform.lock.hcl` is intentionally committed because it locks provider versions. The capstone instructions asked to ignore it, but the recommended production practice is generally to commit the lock file.

---

# Task 4 — Build Custom Modules

Three custom modules were created.

## 1. VPC Module

Location:

```text
modules/vpc/
```

### Inputs

```text
cidr
public_subnet_cidr
environment
project_name
```

### Resources

The module creates:

- VPC
- Public subnet
- Internet Gateway
- Route table
- Route table association

### Outputs

```text
vpc_id
subnet_id
```

The module also applies environment and project tags.

---

## 2. Security Group Module

Location:

```text
modules/security-group/
```

### Inputs

```text
vpc_id
ingress_ports
environment
project_name
```

### Resources

The module creates:

- Security Group
- Dynamic ingress rules
- Allow-all egress

The dynamic ingress rules allow the list of ports passed from the root module.

Example:

```hcl
ingress_ports = [22, 80]
```

creates rules for:

```text
22 → SSH
80 → HTTP
```

### Output

```text
sg_id
```

---

## 3. EC2 Instance Module

Location:

```text
modules/ec2-instance/
```

### Inputs

```text
ami_id
instance_type
subnet_id
security_group_ids
environment
project_name
```

### Resource

The module creates an EC2 instance and applies environment-aware tags.

### Outputs

```text
instance_id
public_ip
```

---

# Task 5 — Workspace-Aware Configuration

The important part of the capstone was connecting Terraform workspaces with the infrastructure configuration.

## `locals.tf`

```hcl
locals {
  environment = terraform.workspace
  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Workspace   = terraform.workspace
  }
}
```

### What this does

If the active workspace is:

```text
dev
```

then:

```text
local.environment = dev
local.name_prefix = terraweek-dev
```

For staging:

```text
terraweek-staging
```

For production:

```text
terraweek-prod
```

This makes resource naming and tagging environment-aware.

---

# Root Variables

The root module uses variables so that infrastructure values are not hardcoded.

```hcl
variable "project_name" {
  type    = string
  default = "terraweek"
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ingress_ports" {
  type    = list(number)
  default = [22, 80]
}
```

---

# Environment Configuration

Each environment has its own `.tfvars` file.

## Dev

```hcl
vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
instance_type = "t2.micro"
ingress_ports = [22, 80]
```

### Dev characteristics

- VPC: `10.0.0.0/16`
- Subnet: `10.0.1.0/24`
- Smaller EC2 instance
- SSH enabled
- HTTP enabled

---

## Staging

```hcl
vpc_cidr      = "10.1.0.0/16"
subnet_cidr   = "10.1.1.0/24"
instance_type = "t2.small"
ingress_ports = [22, 80, 443]
```

### Staging characteristics

- VPC: `10.1.0.0/16`
- Subnet: `10.1.1.0/24`
- Larger instance than Dev
- SSH enabled
- HTTP enabled
- HTTPS enabled

---

## Production

```hcl
vpc_cidr      = "10.2.0.0/16"
subnet_cidr   = "10.2.1.0/24"
instance_type = "t3.small"
ingress_ports = [80, 443]
```

### Production characteristics

- VPC: `10.2.0.0/16`
- Subnet: `10.2.1.0/24`
- Larger instance
- HTTP enabled
- HTTPS enabled
- SSH is not exposed

Different CIDR ranges prevent the VPC networks from overlapping.

---

# Task 6 — Connect the Modules

The root `main.tf` calls the three custom modules.

The dependency flow is:

```text
Root Module
    |
    +---- VPC Module
    |       |
    |       +---- VPC
    |       +---- Subnet
    |       +---- Internet Gateway
    |       +---- Route Table
    |
    +---- Security Group Module
    |       |
    |       +---- Security Group
    |
    +---- EC2 Module
            |
            +---- EC2 Instance
```

The EC2 module receives:

```text
VPC subnet ID
Security Group ID
AMI ID
Instance Type
```

Terraform automatically builds the dependency graph from these references.

---

# Task 7 — Validate the Configuration

Before deployment, Terraform configuration was formatted and validated.

```bash
terraform fmt
terraform validate
```

### Why?

`terraform fmt`

- Formats Terraform files consistently.

`terraform validate`

- Checks Terraform configuration syntax.
- Detects invalid arguments.
- Detects configuration errors before deployment.

A good workflow is:

```text
terraform fmt
      ↓
terraform validate
      ↓
terraform plan
      ↓
terraform apply
```

---

# Task 8 — Deploy Dev Environment

Select the Dev workspace:

```bash
terraform workspace select dev
```

Create the execution plan:

```bash
terraform plan -var-file="dev.tfvars"
```

Apply the configuration:

```bash
terraform apply -var-file="dev.tfvars"
```

This creates the Dev VPC, subnet, security group, and EC2 instance.

---

# Task 9 — Deploy Staging Environment

Select Staging:

```bash
terraform workspace select staging
```

Plan:

```bash
terraform plan -var-file="staging.tfvars"
```

Apply:

```bash
terraform apply -var-file="staging.tfvars"
```

This creates a separate Staging infrastructure environment.

---

# Task 10 — Deploy Production Environment

Select Production:

```bash
terraform workspace select prod
```

Plan:

```bash
terraform plan -var-file="prod.tfvars"
```

Apply:

```bash
terraform apply -var-file="prod.tfvars"
```

Production gets its own VPC, security group, and EC2 instance.

---

# Task 11 — Verify the Environments

Outputs can be checked from each workspace.

## Dev

```bash
terraform workspace select dev
terraform output
```

## Staging

```bash
terraform workspace select staging
terraform output
```

## Prod

```bash
terraform workspace select prod
terraform output
```

### AWS Console Verification

I verified that the environments should have:

| Environment | VPC CIDR | Instance Type | Ports |
|---|---|---|---|
| Dev | `10.0.0.0/16` | `t2.micro` | 22, 80 |
| Staging | `10.1.0.0/16` | `t2.small` | 22, 80, 443 |
| Prod | `10.2.0.0/16` | `t3.small` | 80, 443 |

Expected instance names:

```text
terraweek-dev-server
terraweek-staging-server
terraweek-prod-server
```

### Environment Isolation

The environments are isolated at the Terraform state/workspace and AWS VPC level.

Each environment has:

- Its own Terraform workspace/state
- Its own VPC
- Its own subnet
- Its own security group
- Its own EC2 instance
- Its own CIDR range
- Its own environment-specific configuration

---

# Task 12 — Terraform Best Practices Learned

## 1. File Structure

Keep Terraform configuration organized:

```text
providers.tf
variables.tf
main.tf
outputs.tf
locals.tf
```

This makes the project easier to maintain.

## 2. State Management

Production Terraform should use a remote backend.

Recommended practices:

- Remote state
- State locking
- State versioning
- Encryption at rest
- Restricted backend access

## 3. Variables

Avoid hardcoding environment-specific values.

Use:

```text
dev.tfvars
staging.tfvars
prod.tfvars
```

Use variable validation where appropriate.

## 4. Modules

A module should generally have one clear responsibility.

Good examples:

```text
VPC module
Security Group module
EC2 module
```

Modules should expose clear:

```text
Inputs → Resources → Outputs
```

## 5. Workspaces

Workspaces provide separate state for the same Terraform configuration.

Use:

```hcl
terraform.workspace
```

to make configuration workspace-aware.

## 6. Security

Do not commit:

```text
*.tfstate
*.tfvars
```

to Git.

Use remote state with proper access controls and encryption.

## 7. Terraform Commands

Recommended workflow:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

Always review the plan before applying infrastructure changes.

## 8. Tagging

Resources should have common tags such as:

```text
Project
Environment
ManagedBy
Workspace
```

## 9. Naming

Use a consistent naming convention:

```text
<project>-<environment>-<resource>
```

Examples:

```text
terraweek-dev-server
terraweek-staging-server
terraweek-prod-server
```

## 10. Cleanup

Destroy temporary/non-production infrastructure when it is no longer required.

This helps avoid unnecessary AWS charges.

---

# Task 13 — Destroy All Environments

The environments were destroyed in reverse order.

## Destroy Production

```bash
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"
```

## Destroy Staging

```bash
terraform workspace select staging
terraform destroy -var-file="staging.tfvars"
```

## Destroy Dev

```bash
terraform workspace select dev
terraform destroy -var-file="dev.tfvars"
```

After destruction, AWS was checked to confirm that the infrastructure was removed.

Expected resources to be gone:

- VPCs
- Subnets
- Internet Gateways
- Route Tables
- Security Groups
- EC2 Instances

---

# Delete Workspaces

After destroying the resources:

```bash
terraform workspace select default

terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod
```

The `default` workspace was kept because Terraform requires a workspace to be selected.

---

# What I Did in This Task

In Day 67, I combined the Terraform concepts learned throughout TerraWeek into one complete capstone project.

### My work

1. Learned how Terraform workspaces work.
2. Created `dev`, `staging`, and `prod` workspaces.
3. Created a clean Terraform project structure.
4. Created three custom modules:
   - VPC
   - Security Group
   - EC2 Instance
5. Used module inputs and outputs to connect infrastructure.
6. Used `terraform.workspace` for environment-aware configuration.
7. Created separate `.tfvars` files for each environment.
8. Configured different VPC CIDRs for each environment.
9. Configured different EC2 instance sizes.
10. Configured environment-specific security group ports.
11. Added common environment and project tags.
12. Used `terraform fmt` and `terraform validate`.
13. Planned and deployed each environment separately.
14. Verified the infrastructure in AWS.
15. Destroyed all environments after verification.
16. Deleted the Terraform workspaces.

---

# Final Architecture

```text
                    TerraWeek Capstone
                           |
                    Terraform Root
                           |
              +------------+------------+
              |            |            |
             DEV         STAGING       PROD
              |            |            |
          Workspace     Workspace    Workspace
              |            |            |
              +------------+------------+
                           |
                    Custom Modules
                           |
          +----------------+----------------+
          |                |                |
       VPC Module     Security Group    EC2 Module
          |                |                |
       VPC/Subnet           SG             EC2
          |
     Internet Gateway
          |
      Route Table
```

---

# Key Takeaways

> **One Terraform codebase + reusable modules + separate workspaces + environment-specific variables = scalable multi-environment infrastructure.**

### Remember

```text
Workspace → Separate State
Module    → Reusable Infrastructure
Variables → Flexible Configuration
Outputs   → Share Resource Information
Locals    → Simplify Expressions
tfvars    → Environment-Specific Values
Tags      → Resource Organization
Plan      → Review Changes
Apply     → Create/Modify Infrastructure
Destroy   → Clean Up Resources
```

## Interview Questions

### What is a Terraform workspace?

A workspace is a separate state environment that allows the same Terraform configuration to manage multiple infrastructure instances.

### Why use modules?

Modules allow infrastructure to be packaged into reusable components and reduce code duplication.

### Why use `terraform.workspace`?

It allows the configuration to detect the active workspace and change names, tags, or other behavior based on the environment.

### Why use separate `.tfvars` files?

They allow the same Terraform configuration to use different values for Dev, Staging, and Production.

### How are the environments isolated?

Each environment has its own workspace/state and separate AWS resources such as VPCs, subnets, security groups, and EC2 instances.

### Why should Terraform state not be committed to Git?

State can contain sensitive information and should be protected using a secure remote backend.

### What is the recommended Terraform workflow?

```text
fmt
 ↓
validate
 ↓
plan
 ↓
review
 ↓
apply
 ↓
verify
 ↓
destroy when required
```

---

# Day 67 Summary

**Day 67 completed the TerraWeek Terraform journey by combining custom modules, workspaces, variables, outputs, state management, and AWS resources into a multi-environment infrastructure project.**

The main concept learned was:

```text
Write infrastructure once
        ↓
Create reusable modules
        ↓
Use workspaces for environments
        ↓
Use tfvars for environment values
        ↓
Deploy Dev / Staging / Prod
        ↓
Verify
        ↓
Destroy cleanly
```

**Day 67 = Terraform Capstone + Multi-Environment Infrastructure + Workspaces + Custom Modules**

