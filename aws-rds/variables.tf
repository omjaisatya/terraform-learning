variable "region" {
  type        = string
  description = "AWS deployment region"
  default     = "ap-south-1"
}

variable "db_username" {
  type        = string
  description = "PostgreSQL master username"
  default     = "adminuser"
}

variable "db_password" {
  type        = string
  description = "PostgreSQL master password"
  sensitive   = true
}
