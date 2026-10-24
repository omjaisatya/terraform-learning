# Terraform CLI Command Reference

This cheat sheet summarizes the essential Terraform CLI commands, common flags, and debugging variables used in day-to-day operations.

## Core Lifecycle Commands

### terraform init

Initializes working directory containing Terraform configuration files.

```bash
# Basic initialization
terraform init

# Upgrade providers to the latest allowed version
terraform init -upgrade

# Reconfigure backend settings, migrating existing state
terraform init -migrate-state

# Reconfigure backend, ignoring existing configuration
terraform init -reconfigure
```

### terraform fmt

Rewrites configuration files to canonical format and style.

```bash
# Format current directory
terraform fmt

# Format recursively in subdirectories
terraform fmt -recursive

# Check if files are formatted without altering them (returns exit code 3 if non-compliant)
terraform fmt -check -diff
```

### terraform validate

Validates HCL syntax and internal references without connecting to remote APIs.

```bash
terraform validate
```

### terraform plan

Compares configuration with state and cloud infrastructure, calculating changes.

```bash
# Basic plan
terraform plan

# Save plan to a binary file for reliable application
terraform plan -out=tfplan.binary

# Target a specific resource (use sparingly, can skip dependencies)
terraform plan -target=aws_instance.webserver

# Refresh state only to detect drift without planning resource modifications
terraform plan -refresh-only

# Provide custom variable file
terraform plan -var-file="production.tfvars"
```

### terraform apply

Applies changes required to reach desired state of configuration.

```bash
# Interactive apply with user confirmation prompt
terraform apply

# Apply a previously saved plan file
terraform apply tfplan.binary

# Apply without interactive prompt (standard in CI/CD pipelines)
terraform apply -auto-approve

# Apply while passing variable overrides
terraform apply -var="instance_type=t3.small"
```

### terraform destroy

Destroys all infrastructure managed by the current workspace.

```bash
# Interactive destroy
terraform destroy

# Non-interactive destroy
terraform destroy -auto-approve

# Destroy a specific targeted resource
terraform destroy -target=aws_instance.legacy_box
```

## Inspection and State Commands

### terraform show

Provides human-readable output from a state or plan file.

```bash
# Inspect current state file
terraform show

# Inspect binary plan file
terraform show tfplan.binary

# Output in JSON format for automated policy checks (e.g., OPA or jq)
terraform show -json tfplan.binary | jq .
```

### terraform output

Reads output variables from state file.

```bash
# List all outputs
terraform output

# Get specific output value
terraform output server_public_ip

# Extract raw string without quotes (ideal for shell scripts)
terraform output -raw server_public_ip
```

### terraform console

Interactive command-line console for evaluating HCL expressions and built-in functions.

```bash
terraform console
# Inside console:
# > cidrsubnet("10.0.0.0/16", 8, 2)
# > merge({ a = 1 }, { b = 2 })
# > exit
```

### terraform graph

Generates visual representation of the dependency graph in DOT format.

```bash
# Generate graph and render to PNG using Graphviz
terraform graph | dot -Tpng > graph.png
```

## Debugging Environment Variables

Set these environment variables in your terminal when troubleshooting provider or engine issues:

```bash
# Set logging level: TRACE, DEBUG, INFO, WARN, ERROR
export TF_LOG=DEBUG

# Direct logs to a dedicated file
export TF_LOG_PATH="./terraform_debug.log"

# Trace only specific provider logs
export TF_LOG_PROVIDER=TRACE

# Provider plugin caching to avoid repeated binary downloads
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
```
