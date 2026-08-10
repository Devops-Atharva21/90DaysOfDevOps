variable "aws_vpc_name" {
  description = "This variable holds VPC name"
  default     = "test"
  type        = string
}


variable "aws_region_name" {
  description = "This variable holds Instance Region"
  default     = "us-west-2"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "This variable holds VPC CIDR"
  default     = "10.0.0.0/16"
  type        = string
}

variable "aws_subnet_cidr" {
  description = "This variable holds Subnet CIDR"
  default     = "10.0.1.0/24"
  type        = string
}

variable "instance_type" {
  description = "This variable holds EC2 instance type"
  default     = "t3.micro"
  type        = string
}

variable "environment" {
  description = "This variable holds EC2 environment"
  type        = string
  default     = "dev"
}

variable "allowed_port" {
  description = "Lists of port allow in security group"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "project_name" {
  description = "Project Name"
  type        = string
}


variable "extra_tags" {
  description = "Additional tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}

