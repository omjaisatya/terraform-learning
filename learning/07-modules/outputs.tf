output "web_sg_id" {
  description = "Security Group ID for web tier exported by child module"
  value       = module.web_security_group.security_group_id
}

output "db_sg_id" {
  description = "Security Group ID for db tier exported by child module"
  value       = module.db_security_group.security_group_id
}
