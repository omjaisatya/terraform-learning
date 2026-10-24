terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

locals {
  # Active workspace name (e.g., default, dev, staging, prod)
  current_env = terraform.workspace

  # Instance type selection based on active workspace
  instance_types = {
    default = "t3.micro"
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }

  # Multi-AZ enablement only for production
  multi_az_enabled = local.current_env == "prod" ? true : false

  # Selected instance size
  selected_instance_type = lookup(local.instance_types, local.current_env, "t3.micro")
}

# Example EC2 instance configured according to the current workspace
resource "aws_instance" "app_node" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = local.selected_instance_type

  tags = {
    Name        = "app-server-${local.current_env}"
    Environment = local.current_env
    Workspace   = terraform.workspace
  }
}

output "active_workspace" {
  description = "The active workspace used during apply"
  value       = terraform.workspace
}

output "deployed_instance_size" {
  description = "Instance size selected for the workspace"
  value       = local.selected_instance_type
}
