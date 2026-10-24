output "computed_resource_prefix" {
  description = "Standardized prefix generated for resources"
  value       = local.resource_prefix
}

output "applied_tags" {
  description = "Full map of merged resource tags"
  value       = local.effective_tags
}

output "primary_allowed_cidr" {
  description = "The first CIDR block from the allowed list"
  value       = var.allowed_cidr_blocks[0]
}

output "cluster_storage_gb" {
  description = "Configured cluster storage capacity in gigabytes"
  value       = var.cluster_config.storage_size
}

output "masked_secret_key" {
  description = "Demonstration of sensitive output flag"
  value       = var.secret_api_key
  sensitive   = true
}
