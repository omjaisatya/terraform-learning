terraform {
  required_version = ">= 1.5.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

# Variable defining environments as a map for for_each demonstration
variable "environments" {
  type = map(object({
    log_level = string
    replicas  = number
  }))
  default = {
    development = {
      log_level = "DEBUG"
      replicas  = 1
    }
    staging = {
      log_level = "INFO"
      replicas  = 2
    }
    production = {
      log_level = "WARN"
      replicas  = 5
    }
  }
}

# Base configuration file (prerequisite)
resource "local_file" "base_config" {
  filename = "${path.module}/configs/base.json"
  content  = jsonencode({ system = "core-engine", active = true })

  lifecycle {
    # Guarantees file cannot be destroyed accidentally
    prevent_destroy = false
  }
}

# Demonstrating for_each and explicit depends_on
resource "local_file" "env_configs" {
  for_each = var.environments

  filename = "${path.module}/configs/${each.key}.json"
  content = jsonencode({
    environment = each.key
    log_level   = each.value.log_level
    replicas    = each.value.replicas
    base_synced = true
  })

  # Explicit dependency: base_config must be written first
  depends_on = [
    local_file.base_config
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Demonstrating count for ephemeral scratch notes
variable "scratch_note_count" {
  type    = number
  default = 2
}

resource "local_file" "scratch_notes" {
  count    = var.scratch_note_count
  filename = "${path.module}/scratch/note-${count.index}.txt"
  content  = "Scratch workspace index #${count.index}\n"

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}
