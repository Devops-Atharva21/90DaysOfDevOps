### Variable for security group

variable "vpc_id" {
  description = " This variable holds vpc_id values "
  type        = string
}

variable "sg_name" {
  description = " This variable holds security group values "
  type        = string
}

variable "ingress_ports" {
  description = " This variable holds ingress port values"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = " This variable holds tags "
  type        = map(string)
  default     = {}
}
