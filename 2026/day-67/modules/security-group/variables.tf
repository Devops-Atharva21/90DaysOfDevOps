variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "ingress_ports" {
  description = "Lists of ports alloweed for inbound traffic"
  type        = list(number)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

