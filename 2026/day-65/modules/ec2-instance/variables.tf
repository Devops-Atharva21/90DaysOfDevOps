### variables.tf

variable "ami_id" {
  description = "This variable holds AMI ID values"
  default     = "ami-02167eae61967e403"
  type        = string
}

variable "instance_type" {
  description = "This variable holds instance type"
  default     = "t3.micro"
  type        = string
}

variable "subnet_id" {
  description = "This variable holds subnet id"
  type        = string
}

variable "security_group_id" {
  description = "This variable holds security group id"
  type        = string
}

variable "instance_name" {
  description = "This variable holds instance name"
  default     = "terra-week-inst"
  type        = string
}

variable "tags" {
  description = "This variable holds tag name"
  type        = map(string)
  default     = {}
}

