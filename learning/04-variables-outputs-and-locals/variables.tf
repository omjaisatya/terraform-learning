variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "cloud-platform"
}

variable "environment" {
  type        = string
  description = "Target deployment stage (dev, stage, prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "instance_count" {
  type        = number
  description = "Number of worker nodes to deploy"
  default     = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of allowed IPv4 CIDR blocks for administrative access"
  default     = ["10.0.0.0/16", "192.168.1.0/24"]
}

variable "cluster_config" {
  type = object({
    version      = string
    enable_auth  = bool
    storage_size = number
    backup_retention_days = optional(number, 7)
  })
  description = "Complex object variable defining cluster parameters"
  default = {
    version      = "1.28"
    enable_auth  = true
    storage_size = 50
  }
}

variable "secret_api_key" {
  type        = string
  description = "Sensitive API key used for external system integrations"
  sensitive   = true
}
