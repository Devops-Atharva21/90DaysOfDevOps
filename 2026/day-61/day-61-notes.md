# Day 61 – Introduction to Terraform and Your First AWS Infrastructure

## 🎯 Objective

Today you'll begin learning **Terraform**, one of the most popular Infrastructure as Code (IaC) tools. Instead of manually creating cloud resources through the AWS Console, you'll write code that automatically creates, updates, and deletes infrastructure.

By the end of this day, you'll:
- Install Terraform
- Configure the AWS CLI
- Create an S3 Bucket
- Launch an EC2 Instance
- Understand Terraform State
- Modify infrastructure
- Destroy all created resources

---

# Task 1 – Understand Infrastructure as Code (IaC)

## What is Infrastructure as Code (IaC)?

Infrastructure as Code (IaC) is the process of managing cloud infrastructure using code instead of manually creating resources through a web console.

Example:
Instead of clicking buttons to create an EC2 instance, you simply write a Terraform file and Terraform creates it automatically.

### Why is IaC important?

- Infrastructure can be recreated anytime.
- Reduces manual work.
- Avoids human mistakes.
- Easy to share with teammates.
- Keeps infrastructure version controlled using Git.

---

## Problems solved by IaC

Creating resources manually can lead to:

- Different environments
- Human errors
- Time-consuming deployments
- Difficult recovery if resources are deleted

IaC solves these by making infrastructure repeatable and automated.

---

## Terraform vs Other Tools

### Terraform

- Creates and manages infrastructure.
- Supports AWS, Azure, GCP and many more providers.
- Uses HCL (HashiCorp Configuration Language).

Example:
Create EC2, VPC, S3, Kubernetes clusters.

---

### AWS CloudFormation

- AWS-only IaC tool.
- Uses JSON or YAML.
- Cannot manage Azure or GCP resources.

---

### Ansible

- Configuration Management tool.
- Mainly used after servers are created.
- Installs software and configures servers.

Example:
Install Nginx, Docker, Java etc.

---

### Pulumi

- IaC tool like Terraform.
- Uses programming languages such as Python, JavaScript, Go and C# instead of HCL.

---

## What does Declarative mean?

You only describe **what** you want.

Example:

"I need one EC2 instance."

Terraform figures out **how** to create it.

---

## What does Cloud Agnostic mean?

Terraform can work with multiple cloud providers.

Examples:

- AWS
- Azure
- Google Cloud
- DigitalOcean
- Kubernetes
- VMware

You don't have to learn a different IaC tool for every cloud.

---

# Task 2 – Install Terraform and Configure AWS

## Install Terraform

Install Terraform based on your operating system.

### Ubuntu/Linux

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install terraform
```

### Verify Installation

```bash
terraform -version
```

Expected output:

```text
Terraform v1.x.x
```

---

## Install AWS CLI

Install AWS CLI.

Verify:

```bash
aws --version
```

---

## Configure AWS CLI

Run:

```bash
aws configure
```

Enter:

- Access Key ID
- Secret Access Key
- Region (example: ap-south-1)
- Output format (json)

---

## Verify AWS Credentials

```bash
aws sts get-caller-identity
```

If successful, AWS returns:

- Account ID
- User ARN
- User ID

This confirms Terraform can authenticate with AWS.

---

# Task 3 – Create Your First Terraform Configuration

Create a project.

```bash
mkdir terraform-basics
cd terraform-basics
```

Create a file:

```
main.tf
```

Inside it define:

- Terraform block
- AWS provider
- S3 Bucket resource

Example structure:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "your-unique-bucket-name"
}
```

> **Note:** S3 bucket names must be globally unique. If you get a `BucketAlreadyExists` error, choose a different bucket name.

---

## Terraform Lifecycle

### Initialize

```bash
terraform init
```

Purpose:

- Downloads AWS Provider plugin.
- Creates the `.terraform/` directory.
- Creates `.terraform.lock.hcl`.

---

### Plan

```bash
terraform plan
```

Purpose:

Shows what Terraform **will create**, **modify**, or **delete** before making any changes.

No resources are created yet.

---

### Apply

```bash
terraform apply
```

Purpose:

Actually creates the infrastructure after you confirm with `yes`.

Verify the bucket in the AWS S3 Console.

---

## What is the `.terraform/` folder?

It stores:

- Downloaded provider plugins
- Provider metadata
- Internal Terraform files

This folder is generated automatically.

---

# Task 4 – Add an EC2 Instance

Extend `main.tf` by adding an EC2 instance.

Example:

```hcl
resource "aws_instance" "server" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  tags = {
    Name = "TerraWeek-Day1"
  }
}
```

Run:

```bash
terraform plan
terraform apply
```

Terraform compares the existing state with your code.

Since the S3 bucket already exists, only the EC2 instance will be created.

Verify the EC2 instance in the AWS Console.

---

## How does Terraform know only the EC2 needs to be created?

Terraform checks its **state file (`terraform.tfstate`)**.

The state file already contains the S3 bucket, so Terraform only creates resources that are missing.

---

# Task 5 – Understand Terraform State

Terraform stores all managed resources in:

```
terraform.tfstate
```

This JSON file tracks everything Terraform creates.

---

## View Current State

### Human-readable output

```bash
terraform show
```

Shows all managed resources in a readable format.

---

### List Resources

```bash
terraform state list
```

Example:

```
aws_instance.server
aws_s3_bucket.bucket
```

---

### View One Resource

```bash
terraform state show aws_s3_bucket.bucket
```

or

```bash
terraform state show aws_instance.server
```

Displays detailed information about that resource.

---

## What does the state file store?

It stores:

- Resource IDs
- ARNs
- Public IPs
- Tags
- Attributes
- Dependencies
- Current infrastructure information

---

## Why should you never edit the state file?

Editing it manually may:

- Corrupt the state
- Lose resource tracking
- Cause Terraform to recreate or destroy resources incorrectly

Always let Terraform manage it.

---

## Why shouldn't it be committed to Git?

The state file may contain:

- Sensitive information
- Resource IDs
- IP addresses
- Infrastructure details

In real projects, store it remotely (for example, in an S3 bucket with state locking).

---

# Task 6 – Modify, Plan and Destroy

Modify the EC2 tag.

Before:

```hcl
Name = "TerraWeek-Day1"
```

After:

```hcl
Name = "TerraWeek-Modified"
```

Run:

```bash
terraform plan
```

Terraform compares:

Current State

↓

Desired State

and shows the changes.

---

## Terraform Symbols

| Symbol | Meaning |
|---------|----------|
| + | Resource will be created |
| ~ | Resource will be updated |
| - | Resource will be destroyed |

---

If only the tag changes, Terraform performs an **in-place update**.

No new EC2 instance is created.

Apply the changes:

```bash
terraform apply
```

Verify the updated tag in the AWS Console.

---

## Destroy Everything

When finished:

```bash
terraform destroy
```

Terraform deletes:

- EC2 Instance
- S3 Bucket

Confirm by typing:

```
yes
```

Verify in the AWS Console that all resources have been removed.

---

# Key Takeaways

- Terraform is an Infrastructure as Code (IaC) tool.
- IaC automates cloud infrastructure using code.
- `terraform init` downloads providers and initializes the project.
- `terraform plan` previews changes.
- `terraform apply` creates or updates infrastructure.
- `terraform.tfstate` keeps track of all managed resources.
- Never edit the state file manually.
- Never commit the state file to Git.
- Terraform compares the desired configuration with the current state before making changes.
- Use `terraform destroy` to clean up resources and avoid unnecessary AWS charges.

---

# Commands Cheat Sheet

```bash
# Check Terraform version
terraform -version

# Configure AWS
aws configure

# Verify AWS credentials
aws sts get-caller-identity

# Initialize project
terraform init

# Preview changes
terraform plan

# Create infrastructure
terraform apply

# View current state
terraform show

# List managed resources
terraform state list

# View specific resource
terraform state show aws_s3_bucket.bucket

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate

# Destroy infrastructure
terraform destroy
```
