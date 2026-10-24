# Module 10: Workspaces and Multi-Environment Architecture

## What are Terraform Workspaces?

By default, every Terraform configuration has a single workspace named `default`. Workspaces allow you to have multiple distinct state files associated with the exact same configuration directory.

When using a remote backend (like AWS S3), switching workspaces changes the state file key path automatically:

- Default workspace: `production/terraform.tfstate`
- Dev workspace: `env:/dev/production/terraform.tfstate`
- Staging workspace: `env:/staging/production/terraform.tfstate`

## Workspace CLI Commands

```bash
# List all existing workspaces
terraform workspace list

# Create a new workspace and switch to it
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch between existing workspaces
terraform workspace select prod

# Show current active workspace
terraform workspace show

# Delete an empty workspace (cannot delete default or active workspace)
terraform workspace select default
terraform workspace delete dev
```

## Interpolating `${terraform.workspace}`

Inside your HCL code, you can use the current workspace name to drive sizing, resource counts, and naming:

```hcl
locals {
  environment = terraform.workspace

  # Dynamic instance sizing per workspace
  instance_types = {
    default = "t3.micro"
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "m5.large"
  }

  instance_type = lookup(local.instance_types, local.environment, "t3.micro")
}
```

## Production Trade-offs: Workspaces vs Directory-Based Layout

While workspaces are convenient, using them for major production environments (dev vs staging vs prod) introduces substantial operational risks.

### Risks of CLI Workspaces

1. **Accidental Blast Radius**: If an engineer forgets they are in the `prod` workspace and runs `terraform apply -auto-approve`, production changes occur immediately.
2. **Shared Provider Credentials**: All workspaces in a folder share the same provider credentials and permissions. You cannot give a developer permissions only on `dev` without also granting them access to `prod`.
3. **Identical Codebase Mandate**: Every environment must run the exact same code revision. Testing a major module refactoring in `dev` requires branching or modifying the shared files.

### Recommended Pattern: Directory-Based Separation

In enterprise production architectures, teams separate environments by directory:

```txt
environments/
  dev/
    backend.tf      # State key: environments/dev/terraform.tfstate (Dev AWS Account)
    main.tf         # Calls shared modules with dev parameters
    terraform.tfvars
  staging/
    backend.tf      # State key: environments/staging/terraform.tfstate (Staging AWS Account)
    main.tf
    terraform.tfvars
  prod/
    backend.tf      # State key: environments/prod/terraform.tfstate (Prod AWS Account, strict IAM)
    main.tf
    terraform.tfvars
modules/
  vpc/
  database/
  compute/
```

Benefits:

- Isolated state files in completely different cloud accounts.
- Granular IAM access control (developers have access only to the Dev backend bucket).
- Eliminates human workspace switching errors.
