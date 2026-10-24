terraform {
  required_version = ">= 1.6.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

variable "environment" {
  type        = string
  description = "Target environment"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "service_name" {
  type        = string
  description = "Name of the service"
  default     = "auth-service"
}

locals {
  full_identifier = "${var.service_name}-${var.environment}"
}

# Resource under test
resource "local_file" "config_artifact" {
  filename = "${path.module}/output/${local.full_identifier}.json"
  content = jsonencode({
    service     = var.service_name
    environment = var.environment
    identifier  = local.full_identifier
    active      = true
  })
}

output "artifact_path" {
  value = local_file.config_artifact.filename
}

output "computed_identifier" {
  value = local.full_identifier
}
