# Cross-Stack State Sharing Example
# Reads outputs published by the networking stack state file

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "production-terraform-state-company-2026"
    key    = "infrastructure/network/terraform.tfstate"
    region = "ap-south-1"
  }
}

# Consuming values exposed in the remote state
# Assuming networking state exposes 'vpc_id' and 'private_subnet_ids'
locals {
  target_vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  app_subnet_id      = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
}

output "imported_vpc_id" {
  description = "VPC ID retrieved from remote state"
  value       = local.target_vpc_id
}

output "imported_subnet_id" {
  description = "Subnet ID retrieved from remote state"
  value       = local.app_subnet_id
}
