# Module 04: Variables, Outputs, and Locals

## Variable Types and Structures

Input variables serve as parameters for Terraform modules, making your configuration reusable across multiple environments.

### Primitive Types

- `string`: `"t3.micro"`, `"ap-south-1"`
- `number`: `80`, `3.14`, `20`
- `bool`: `true`, `false`

### Collection Types

- `list(<TYPE>)`: Ordered collection of elements. Example: `list(string)` -> `["us-east-1a", "us-east-1b"]`.
- `set(<TYPE>)`: Unordered collection of unique elements. Duplicates are automatically removed.
- `map(<TYPE>)`: Key-value pairs where all values share the same type. Example: `map(string)` -> `{ env = "prod", tier = "frontend" }`.

### Structural Types

- `object({ <ATTR_NAME> = <TYPE>, ... })`: Complex map-like structure with specific typed fields. Optional attributes can be marked with `optional()`.
- `tuple([<TYPE>, ...])`: Ordered sequence where each element can have a distinct type. Example: `tuple([string, number, bool])`.

## Variable Validation

Use `validation` blocks within variables to enforce business logic before running plans:

```hcl
variable "environment" {
  type        = string
  description = "Target deployment environment"

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "The environment must be one of: dev, stage, prod."
  }
}

variable "db_port" {
  type        = number
  description = "Database port number"
  default     = 5432

  validation {
    condition     = var.db_port > 1024 && var.db_port <= 65535
    error_message = "Database port must be between 1025 and 65535."
  }
}
```

## Sensitive Variables

Mark credentials, tokens, and passwords with `sensitive = true`. This prevents Terraform from printing the values in terminal logs during `plan` or `apply`.

```hcl
variable "database_password" {
  type        = string
  description = "Root administrative password for PostgreSQL"
  sensitive   = true
}
```

*Note*: Marking an attribute sensitive hides it from CLI output, but the raw value remains in `terraform.tfstate`. You must secure the state backend accordingly.

## Variable Precedence (Lowest to Highest)

When the same variable is assigned values in multiple places, Terraform resolves it in this exact order:

1. `default` value in the variable declaration block.
2. `TF_VAR_<variable_name>` environment variables (e.g., `export TF_VAR_environment="staging"`).
3. `terraform.tfvars` file if present.
4. `terraform.tfvars.json` file if present.
5. Any `*.auto.tfvars` or `*.auto.tfvars.json` files, evaluated in alphabetical order.
6. Command line flags: `-var` and `-var-file` (flags evaluated left-to-right on CLI).

## Local Values (`locals`)

While variables are user-configurable inputs, local values are internal constants and computed expressions.

Use locals when:

- Repeating the same expression across multiple resources.
- Constructing standardized naming schemes (`${var.org}-${var.project}-${var.environment}-${resource_type}`).
- Merging mandatory organizational tags with custom resource tags.

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
```

## Output Values

Outputs expose data about your infrastructure:

- Provide values on the CLI after `terraform apply`.
- Expose resource attributes from a child module to a parent module.
- Provide data for other configurations using `terraform_remote_state`.

```hcl
output "database_endpoint" {
  description = "Connection string for the database"
  value       = aws_db_instance.db.endpoint
}

output "admin_token" {
  description = "Administrative API token"
  value       = random_password.token.result
  sensitive   = true # Suppresses output in terminal unless queried with terraform output -raw
}
```
