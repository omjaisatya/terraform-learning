terraform {
  required_version = ">= 1.5.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

variable "app_version" {
  type        = string
  default     = "1.4.0"
  description = "Application version string"
}

# Generates a sample payload file
resource "local_file" "app_manifest" {
  filename = "${path.module}/app_manifest.json"
  content = jsonencode({
    version    = var.app_version
    deployed_at = "2026-10-24"
  })

  # local-exec running upon resource creation
  provisioner "local-exec" {
    command = "echo 'Manifest created for version ${var.app_version}' > ${path.module}/audit.log"
  }

  # destroy-time provisioner executing cleanup
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Manifest destroyed' >> ${path.module}/audit.log"
  }
}

# Demonstrating modern native terraform_data resource (replaces null_resource)
resource "terraform_data" "version_sync_hook" {
  # Triggers re-execution only when the app_version variable changes
  triggers_replace = [
    var.app_version
  ]

  input = var.app_version

  provisioner "local-exec" {
    command = "echo 'Triggering notification webhook for version ${var.app_version}' >> ${path.module}/audit.log"
  }
}

output "tracked_version" {
  description = "Value preserved in terraform_data state"
  value       = terraform_data.version_sync_hook.output
}
