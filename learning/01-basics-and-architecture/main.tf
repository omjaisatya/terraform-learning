terraform {
  required_version = ">= 1.5.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

# Generates a random alphanumeric pet name
resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
}

# Writes a sample config file locally based on the random pet name
resource "local_file" "welcome_note" {
  filename = "${path.module}/generated_welcome.txt"
  content  = "Welcome to Terraform. Generated server ID: ${random_pet.server_name.id}\n"
}

output "generated_server_name" {
  description = "The generated random server name"
  value       = random_pet.server_name.id
}

output "file_path" {
  description = "Path of the created local file"
  value       = local_file.welcome_note.filename
}
