# Module 07: Modules

## What are Terraform Modules?

A module is a container for multiple resources that are used together. Every configuration has at least one module: the **root module**, consisting of the `.tf` files in your main working directory.

A **child module** is a module that is called from another configuration. Modules allow you to:

- Package infrastructure into reusable, testable components.
- Enforce organizational standards (e.g., standard tagging, mandatory encryption, standardized naming conventions).
- Hide complexity behind a clean set of input variables and output values.

## Standard Module Structure

Production-grade modules follow this layout:

```
module-directory/
  README.md         # Documentation: what the module creates, required inputs, and outputs
  main.tf           # Primary resource declarations
  variables.tf      # Input variable declarations with types, defaults, and descriptions
  outputs.tf        # Output variable declarations
  versions.tf       # Terraform and required provider version constraints
```

## Calling a Child Module

Use the `module` block in the parent configuration:

```hcl
module "app_security_group" {
  source = "./modules/security-group"

  # Module inputs
  name        = "app-server-sg"
  description = "Security group for application tier"
  vpc_id      = aws_vpc.main.id
  ingress_ports = [80, 443, 8080]
  tags = {
    Environment = "prod"
  }
}
```

## Module Sources

Terraform supports multiple module sources:

### 1. Local Path

Fastest for internal development within a monorepo. Must start with `./` or `../`.

```hcl
source = "./modules/security-group"
```

### 2. Terraform Public Registry

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
}
```

*Note*: Always pin the `version` argument when referencing registry modules to prevent breaking changes.

### 3. Git Repository (HTTPS / SSH)

Supports branch, tag, or commit SHA references via the `ref` query parameter:

```hcl
# Via SSH with tag reference
source = "git@github.com:myorg/terraform-aws-vpc.git?ref=v2.1.0"

# Via HTTPS
source = "git::https://github.com/myorg/terraform-aws-vpc.git?ref=v2.1.0"
```

## Accessing Module Outputs

Child modules encapsulate their internal resources. A parent module cannot reference `aws_security_group.this.id` directly if it was created inside a child module. The child module must export an `output`, and the parent accesses it via:

```hcl
module.<MODULE_NAME>.<OUTPUT_NAME>
```

Example:

```hcl
resource "aws_instance" "web" {
  vpc_security_group_ids = [
    module.app_security_group.security_group_id
  ]
}
```

## Passing Providers to Child Modules

By default, child modules inherit default provider configurations from the parent. When dealing with provider aliases (e.g., multi-region setups), pass providers explicitly using the `providers` map:

```hcl
module "dr_security_group" {
  source = "./modules/security-group"

  providers = {
    aws = aws.singapore # Maps parent's aws.singapore alias to the child's default aws provider
  }

  name   = "dr-app-sg"
  vpc_id = aws_vpc.dr.id
}
```
