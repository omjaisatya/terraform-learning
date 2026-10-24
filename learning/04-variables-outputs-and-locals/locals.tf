locals {
  # Standardized prefix for all cloud resources
  resource_prefix = "${var.project_name}-${var.environment}"

  # Base organization tags required on all resources
  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    CreatedAt   = "2026"
  }

  # Additional tags applied dynamically based on the environment
  environment_tags = var.environment == "prod" ? {
    MonitoringTier = "gold"
    BackupPolicy   = "daily"
    Compliance     = "pci-dss"
  } : {
    MonitoringTier = "standard"
    BackupPolicy   = "none"
    Compliance     = "internal"
  }

  # Merged tags object ready to assign to resources
  effective_tags = merge(local.base_tags, local.environment_tags)
}
