Day 65 — Terraform Modules: Build Reusable Infrastructure
Goal
Today I learned Terraform Modules.
Instead of putting all Terraform resources inside one large `main.tf`, I learned how to split infrastructure into reusable modules.
Think of a Terraform module like a function in programming:
Write the infrastructure code once.
Pass values as inputs.
Reuse the module many times.
Get useful values back as outputs.
---
Expected Output
By the end of Day 65, I created:
A custom EC2 module
A custom Security Group module
Two EC2 instances using the same EC2 module
A Security Group module connected to the EC2 module
A VPC using the public Terraform Registry module
Root outputs for EC2 public IPs
`day-65-modules.md` notes
---
Task 1 — Understand Module Structure
What I did
I created a standard Terraform project structure:
```text
terraform-modules/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── modules/
    ├── ec2-instance/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── security-group/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
Each module contains its own Terraform files.
Root Module
The root module is the main Terraform project where I run commands such as:
```bash
terraform init
terraform plan
terraform apply
```
The root module calls the child modules.
Example:
```hcl
module "web_server" {
  source = "./modules/ec2-instance"
}
```
Child Module
A child module is a reusable module called by the root module.
For example:
```text
modules/ec2-instance/
```
contains the reusable EC2 configuration.
Simple Difference
Root Module	Child Module
Main project	Reusable component
Calls other modules	Contains reusable resources
Usually contains environment-level configuration	Usually focuses on one responsibility
Terraform commands are normally run here	Called by the root module
Key Idea
```text
Root Module
    |
    +-- EC2 Module
    |
    +-- Security Group Module
    |
    +-- VPC Module
```
---
Task 2 — Build a Custom EC2 Module
What I did
I created:
```text
modules/ec2-instance/
├── main.tf
├── variables.tf
└── outputs.tf
```
The purpose of this module is to create an EC2 instance in a reusable way.
---
2.1 — variables.tf
I defined the inputs required by the EC2 module:
```hcl
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "instance_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
```
Why variables?
Variables make the module reusable.
For example, I can use:
```hcl
instance_name = "terraweek-web"
```
for one EC2 instance and:
```hcl
instance_name = "terraweek-api"
```
for another instance.
The module code does not need to change.
---
2.2 — main.tf
The module contains the EC2 resource:
```hcl
resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )
}
```
Important Concept — `merge()`
I used `merge()` to combine common tags with the EC2 `Name` tag.
For example:
```hcl
var.tags = {
  Environment = "dev"
  Project     = "terraweek"
}
```
and:
```hcl
Name = "terraweek-web"
```
become:
```text
Environment = dev
Project     = terraweek
Name        = terraweek-web
```
---
2.3 — outputs.tf
I exposed useful EC2 information:
```hcl
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

output "private_ip" {
  value = aws_instance.this.private_ip
}
```
Why outputs?
The root module can use these values.
For example:
```hcl
module.web_server.public_ip
```
can return the public IP of the EC2 instance created by the module.
---
Task 3 — Build a Custom Security Group Module
What I did
I created:
```text
modules/security-group/
├── main.tf
├── variables.tf
└── outputs.tf
```
This module creates a reusable Security Group.
---
3.1 — variables.tf
I created these inputs:
```hcl
variable "vpc_id" {
  type = string
}

variable "sg_name" {
  type = string
}

variable "ingress_ports" {
  type    = list(number)
  default = [22, 80]
}

variable "tags" {
  type    = map(string)
  default = {}
}
```
The important variable here is:
```hcl
ingress_ports
```
It allows me to pass multiple ports.
Example:
```hcl
ingress_ports = [22, 80, 443]
```
---
3.2 — main.tf
I created the Security Group and used a `dynamic` block:
```hcl
resource "aws_security_group" "this" {
  name   = var.sg_name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
```
What is a Dynamic Block?
Normally, I would have to write separate ingress blocks:
```text
Port 22
Port 80
Port 443
```
With a dynamic block, Terraform loops through:
```hcl
ingress_ports = [22, 80, 443]
```
and creates the required ingress blocks automatically.
Simple Flow
```text
[22, 80, 443]
      |
      v
dynamic "ingress"
      |
      v
22 → SSH
80 → HTTP
443 → HTTPS
```
This makes the module flexible and reusable.
---
3.3 — outputs.tf
I exposed the Security Group ID:
```hcl
output "sg_id" {
  value = aws_security_group.this.id
}
```
The root module can then use:
```hcl
module.web_sg.sg_id
```
---
Task 4 — Call the Custom Modules from Root
What I did
I called the Security Group module from the root module.
```hcl
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = aws_vpc.main.id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}
```
What happened?
The root module passed values to the Security Group child module.
```text
Root Module
     |
     | vpc_id
     | sg_name
     | ingress_ports
     | tags
     v
Security Group Module
     |
     v
AWS Security Group
```
---
Create Two EC2 Instances Using One Module
This was one of the most important parts of the task.
I reused the same EC2 module twice.
Web Server
```hcl
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}
```
API Server
```hcl
module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```
Important Learning
I did not copy and paste the EC2 resource twice.
Instead:
```text
Same EC2 Module
      |
      +----> Web Server
      |
      +----> API Server
```
This is the main benefit of Terraform modules.
---
Module-to-Module Dependency
The EC2 modules use the Security Group created by the Security Group module:
```hcl
security_group_ids = [module.web_sg.sg_id]
```
Terraform understands this dependency.
```text
Security Group Module
        |
        | sg_id
        v
   EC2 Modules
   /          \
Web Server   API Server
```
Terraform creates resources in the correct dependency order.
---
Root Outputs
I created outputs for the EC2 public IP addresses:
```hcl
output "web_server_ip" {
  value = module.web_server.public_ip
}

output "api_server_ip" {
  value = module.api_server.public_ip
}
```
Now I can run:
```bash
terraform output
```
and see the IP addresses.
---
Terraform Commands
I used:
```bash
terraform init
```
Purpose
Initializes Terraform and links/downloads required modules and providers.
Then:
```bash
terraform plan
```
Purpose
Shows what Terraform plans to create, modify, or destroy.
Then:
```bash
terraform apply
```
Purpose
Actually creates the infrastructure.
---
Verification
After applying, I checked AWS and verified:
Two EC2 instances were running.
Both instances used the same Security Group.
The instances had different names.
The Web Server had the name `terraweek-web`.
The API Server had the name `terraweek-api`.
---
Task 5 — Use a Public Registry Module
What I did
Instead of manually creating every VPC resource, I used a public module from the Terraform Registry.
Example:
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  tags = local.common_tags
}
```
Why use a public module?
Someone has already written and tested the VPC infrastructure code.
Instead of creating:
```text
VPC
Internet Gateway
Route Tables
Subnets
NAT Gateway
Route Associations
...
```
manually, I can use the module and provide inputs.
---
Connecting the VPC Module
After using the VPC module, I updated my other modules.
The VPC ID comes from:
```hcl
module.vpc.vpc_id
```
The first public subnet comes from:
```hcl
module.vpc.public_subnets[0]
```
For example:
```hcl
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}
```
And:
```hcl
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}
```
---
Terraform Registry Module Location
After running:
```bash
terraform init
```
Terraform downloads the registry module into:
```text
.terraform/modules/
```
I can inspect this directory to see the downloaded module.
Important:
```text
.terraform/
```
is Terraform's working directory and is normally not committed to Git.
---
Task 6 — Module Versioning and Best Practices
Module Versioning
I learned that Terraform modules can have version constraints.
Exact Version
```hcl
version = "5.1.0"
```
This requests exactly version `5.1.0`.
Minor Version Range
```hcl
version = "~> 5.0"
```
This allows compatible `5.x` releases according to Terraform's version constraint rules.
Custom Range
```hcl
version = ">= 5.0, < 6.0"
```
This allows versions from `5.0` up to, but not including, `6.0`.
---
Upgrade Modules
I can check for newer allowed module versions with:
```bash
terraform init -upgrade
```
This tells Terraform to upgrade modules/providers where the configured constraints allow it.
---
Check Modules in Terraform State
I used:
```bash
terraform state list
```
Modules appear in resource addresses with prefixes such as:
```text
module.vpc.
module.web_server.
module.api_server.
module.web_sg.
```
Example:
```text
module.web_server.aws_instance.this
module.api_server.aws_instance.this
module.web_sg.aws_security_group.this
```
This shows that Terraform tracks resources created through modules.
---
Destroy Infrastructure
After completing the practice, I removed the infrastructure with:
```bash
terraform destroy
```
This is important when practicing on AWS because unused resources can create charges.
---
Five Terraform Module Best Practices
1. Pin Module Versions
Use a version constraint for registry modules.
```hcl
version = "~> 5.0"
```
This makes module behavior more predictable.
---
2. Keep Modules Focused
A module should generally have one clear responsibility.
Examples:
```text
ec2-instance → EC2 infrastructure

security-group → Security Group infrastructure

vpc → VPC infrastructure
```
Avoid creating one huge module containing everything.
---
3. Use Variables
Avoid hardcoding values inside reusable modules.
Instead of:
```hcl
instance_type = "t2.micro"
```
inside the module, use:
```hcl
instance_type = var.instance_type
```
This makes the module reusable.
---
4. Define Outputs
Outputs allow the parent/root module to use important values from the child module.
Example:
```hcl
output "sg_id" {
  value = aws_security_group.this.id
}
```
The caller can then use:
```hcl
module.web_sg.sg_id
```
---
5. Add README.md
A custom module should have documentation explaining:
What the module does
Required variables
Optional variables
Outputs
Example usage
Important notes
Example:
```text
modules/
└── ec2-instance/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```
---
Day 65 — Key Concepts Learned
Terraform Module
A reusable collection of Terraform configuration.
Root Module
The main Terraform project that calls other modules.
Child Module
A reusable module called by the root module.
Module Input
Variables passed into a module.
Example:
```hcl
instance_type = "t2.micro"
```
Module Output
A value exposed by a module.
Example:
```hcl
module.web_server.public_ip
```
Local Module
A module stored inside the current project:
```hcl
source = "./modules/ec2-instance"
```
Registry Module
A module downloaded from the Terraform Registry:
```hcl
source = "terraform-aws-modules/vpc/aws"
```
Dynamic Block
Generates repeated nested blocks from a collection.
Example:
```hcl
dynamic "ingress" {
  for_each = var.ingress_ports
}
```
---
Day 65 Architecture
```text
                    Root Module
                        |
          +-------------+-------------+
          |             |             |
          v             v             v
      VPC Module    Security Group   EC2 Module
      (Registry)       Module       /          \
          |              |          /            \
          |              |         v              v
          |              +----> Web Server     API Server
          |                         |
          +-------------------------+
                    AWS Infrastructure
```
---
Day 65 Quick Revision
```text
Module = Reusable Terraform code

Root Module
    ↓
Calls Child Modules
    ↓
Passes Variables
    ↓
Child Module creates Resources
    ↓
Child Module returns Outputs
    ↓
Root Module uses Outputs
```
Important Commands
```bash
terraform init
terraform plan
terraform apply
terraform init -upgrade
terraform state list
terraform destroy
```
Important Module Syntax
```hcl
module "example" {
  source = "./modules/example"

  variable_name = value
}
```
Important Module References
```hcl
module.web_server.public_ip
module.web_sg.sg_id
module.vpc.vpc_id
module.vpc.public_subnets[0]
```
---
Final Takeaway
Day 65 taught me how to move from a large Terraform configuration to reusable infrastructure components.
The biggest lesson is:
> **Write infrastructure once, then reuse it with different inputs.**
Instead of creating two separate EC2 resource blocks, I created one EC2 module and called it twice.
I also learned how to:
Create custom modules
Pass variables into modules
Return values using outputs
Connect modules together
Use dynamic blocks
Use public Terraform Registry modules
Pin module versions
Inspect modules in Terraform state
Follow basic module best practices
This makes Terraform code cleaner, easier to maintain, and easier to reuse across different environments.
