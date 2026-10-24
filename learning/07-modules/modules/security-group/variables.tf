variable "name" {
  type        = string
  description = "Security group name"
}

variable "description" {
  type        = string
  description = "Description of security group purpose"
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group is created"
}

variable "ingress_ports" {
  type        = list(number)
  description = "List of TCP ports to allow for ingress traffic"
  default     = []
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of IPv4 CIDR blocks permitted for ingress"
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to append to the security group"
  default     = {}
}
