variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID. Can also be set via ARM_SUBSCRIPTION_ID environment variable."
  default     = ""
}

variable "location" {
  type        = string
  description = "Azure region for deployment"
  default     = "West India"
}

variable "admin_username" {
  type        = string
  description = "Administrator username for Linux VM"
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "Administrator password for Linux VM"
  sensitive   = true
}
