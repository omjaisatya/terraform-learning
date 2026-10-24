terraform {
  required_version = ">= 1.5.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

# Input variables for demonstrating expressions and functions
variable "base_cidr" {
  type        = string
  default     = "10.100.0.0/16"
  description = "Base VPC CIDR block"
}

variable "services" {
  type = list(object({
    name      = string
    port      = number
    is_public = bool
  }))
  default = [
    { name = "frontend", port = 80, is_public = true },
    { name = "api", port = 8080, is_public = true },
    { name = "database", port = 5432, is_public = false },
    { name = "cache", port = 6379, is_public = false }
  ]
}

locals {
  # 1. IP Function: Subnet calculation
  calculated_subnets = [
    cidrsubnet(var.base_cidr, 8, 1), # 10.100.1.0/24
    cidrsubnet(var.base_cidr, 8, 2), # 10.100.2.0/24
    cidrsubnet(var.base_cidr, 8, 3)  # 10.100.3.0/24
  ]

  # 2. for expression with filtering: Only keep public services
  public_services = [for s in var.services : s if s.is_public]

  # 3. for expression to create a map: port lookup by service name
  service_port_map = { for s in var.services : s.name => s.port }

  # 4. Built-in string and collection functions
  all_service_names = join(", ", [for s in var.services : upper(s.name)])

  # 5. Render shell script template using templatefile
  rendered_user_data = templatefile("${path.module}/userdata.tpl", {
    app_name        = "OrderProcessor"
    environment     = "production"
    listen_port     = local.service_port_map["api"]
    database_host   = cidrhost(local.calculated_subnets[0], 10)
  })
}

# Write rendered template to disk to inspect output
resource "local_file" "rendered_script" {
  filename = "${path.module}/output/bootstrap.sh"
  content  = local.rendered_user_data
}

# Output calculations
output "calculated_subnets" {
  value = local.calculated_subnets
}

output "public_service_names" {
  value = [for s in local.public_services : s.name]
}

output "service_port_map" {
  value = local.service_port_map
}

output "summary_string" {
  value = local.all_service_names
}
