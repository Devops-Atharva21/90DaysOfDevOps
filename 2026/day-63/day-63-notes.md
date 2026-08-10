# Day 63 – Variables, Outputs, Data Sources & Expressions

## 🎯 Goal

Convert the Day 62 Terraform configuration from **hardcoded values** to a **dynamic, reusable, and environment-aware configuration**.

---

## Task 1: Extract Variables

### What I did

Created `variables.tf` and defined variables for:

* `region`
* `vpc_cidr`
* `subnet_cidr`
* `instance_type`
* `project_name`
* `environment`
* `allowed_ports`
* `extra_tags`

Then replaced hardcoded values in `main.tf` with:

```hcl
var.variable_name
```

`project_name` has no default value, so Terraform asks for it during `plan/apply`.

### Terraform Variable Types

| Type     | Example         |
| -------- | --------------- |
| `string` | `"dev"`         |
| `number` | `2`             |
| `bool`   | `true`          |
| `list`   | `["22", "80"]`  |
| `map`    | `{env = "dev"}` |

---

## Task 2: Variable Files & Precedence

### What I did

Created two variable files:

```text
terraform.tfvars
prod.tfvars
```

Used the default variables:

```bash
terraform plan
```

Used production variables:

```bash
terraform plan -var-file="prod.tfvars"
```

Overrode a variable using CLI:

```bash
terraform plan -var="instance_type=t2.nano"
```

Used an environment variable:

```bash
export TF_VAR_environment="staging"
```

### Variable Precedence

From **lowest → highest priority**:

```text
Variable defaults
↓
Environment variables (TF_VAR_*)
↓
terraform.tfvars / *.auto.tfvars
↓
-var-file
↓
-var
```

---

## Task 3: Outputs

### What I did

Created `outputs.tf` to display important infrastructure information:

* VPC ID
* Subnet ID
* EC2 Instance ID
* Public IP
* Public DNS
* Security Group ID

Useful commands:

```bash
terraform apply
terraform output
terraform output instance_public_ip
terraform output -json
```

### Purpose

Outputs make it easy to get important values from Terraform after deployment.

---

## Task 4: Data Sources

### What I did

Instead of hardcoding an AMI ID, I used an AWS AMI data source.

It dynamically finds the latest matching Amazon Linux AMI.

Also used:

```hcl
data "aws_availability_zones"
```

to get available Availability Zones.

Used the first AZ:

```hcl
data.aws_availability_zones.available.names[0]
```

### Resource vs Data Source

**Resource:** Creates or manages infrastructure.

```hcl
resource "aws_instance" "server" {}
```

**Data Source:** Reads existing information from AWS.

```hcl
data "aws_ami" "amazon_linux" {}
```

---

## Task 5: Locals & Dynamic Values

### What I did

Created local values to avoid repeating the same expressions.

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

Used:

```hcl
local.name_prefix
local.common_tags
```

for resource names and tags.

Used `merge()` to combine common and resource-specific tags:

```hcl
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-server"
})
```

### Benefit

All resources now have **consistent and dynamic names/tags**.

---

## Task 6: Functions & Conditional Expressions

Practiced functions using:

```bash
terraform console
```

### Useful Functions

**1. `upper()`** – Converts text to uppercase.

```hcl
upper("terraweek")
```

**2. `join()`** – Joins list values into a string.

```hcl
join("-", ["terra", "week", "2026"])
```

**3. `length()`** – Returns the number of items.

```hcl
length(["a", "b", "c"])
```

**4. `lookup()`** – Gets a value from a map.

```hcl
lookup({dev = "t2.micro", prod = "t3.small"}, "dev")
```

**5. `cidrsubnet()`** – Creates a subnet CIDR from a larger CIDR.

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)
```

### Conditional Expression

Used a condition to select the EC2 instance type:

```hcl
instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
```

Meaning:

```text
If environment = prod → t3.small
Otherwise              → t2.micro
```

---

# 📝 Day 63 Key Takeaways

* **Variables** → Make Terraform configurations reusable.
* **tfvars** → Store environment-specific values.
* **Outputs** → Display useful infrastructure information.
* **Data Sources** → Read existing/dynamic AWS information.
* **Locals** → Store reusable expressions and values.
* **Functions** → Transform and work with Terraform data.
* **Conditionals** → Create environment-based configurations.
* **No hardcoding** → Makes Terraform easier to maintain and reuse.

### Final Flow

```text
Variables
   ↓
.tfvars
   ↓
Terraform Configuration
   ↓
Data Sources + Locals + Functions
   ↓
AWS Infrastructure
   ↓
Outputs
```

