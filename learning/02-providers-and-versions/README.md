# Module 02: Providers and Versions

## Provider Fundamentals

A Terraform provider is an executable plugin that understands API interactions and exposes resources. Providers are decoupled from Terraform Core and published on the Terraform Registry (`registry.terraform.io`).

## Provider Source Syntax

The `source` attribute in `required_providers` defines where to fetch the plugin:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

The source address structure is `[HOSTNAME]/[NAMESPACE]/[TYPE]`:

- `HOSTNAME`: Optional. Defaults to `registry.terraform.io`. Custom registries (like private registries in Terraform Enterprise) use their domain name.
- `NAMESPACE`: Organizational namespace on the registry (e.g., `hashicorp`, `datadog`, `azure`).
- `TYPE`: The short provider name (e.g., `aws`, `azurerm`, `random`).

## Version Constraint Operators

Terraform supports multiple comparison operators for pinning versions:

- `= 5.30.0`: Exact version match only.
- `!= 5.30.0`: Exclude a specific buggy version.
- `> 5.0.0`: Greater than version 5.0.0.
- `>= 5.0.0`: Greater than or equal to 5.0.0.
- `< 6.0.0`: Less than 6.0.0.
- `<= 5.30.0`: Less than or equal to 5.30.0.
- `~> 5.30.0`: Pessimistic constraint operator (allows patch releases: `>= 5.30.0` and `< 5.31.0`).
- `~> 5.0`: Allows minor updates (allows `>= 5.0` and `< 6.0`).

### Production Best Practice for Version Pinning

Use `~> X.Y` for providers in production root modules, or commit `.terraform.lock.hcl` to source control. The lock file records exact checksums of provider binaries, ensuring identical provider builds across developer workstations and CI/CD runners.

## Provider Aliases (Multi-Region / Multi-Account)

By default, resource blocks inherit the default configuration of their provider. When you need to deploy resources across multiple regions or accounts simultaneously, use provider aliases.

1. Declare a primary provider block without an alias.
2. Declare additional provider blocks with an `alias` argument.
3. In resources, reference the alias using `provider = <provider_name>.<alias_name>`.

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_vpc" "east_network" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "west_network" {
  provider   = aws.west
  cidr_block = "10.2.0.0/16"
}
```

## Plugin Caching

By default, every `terraform init` downloads provider binaries into the local project directory under `.terraform/providers`. When working with multiple workspaces or repositories, this wastes disk space and bandwidth.

Configure global plugin caching in `~/.terraformrc` (Linux/macOS) or `%APPDATA%\terraform.rc` (Windows):

```hcl
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
```

Or set the environment variable:

```bash
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p "$HOME/.terraform.d/plugin-cache"
```

## Authentication Security

Never hardcode cloud API keys, secrets, or subscription tokens in provider blocks:

Incorrect:

```hcl
# Dangerous: Secrets committed to Git
provider "aws" {
  access_key = "AKIAEXAMPLE123456"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}
```

Correct:
Rely on environment variables, standard profile configurations, or IAM role assumption:

```bash
# AWS CLI standard environment variables
export AWS_ACCESS_KEY_ID="AKIAEXAMPLE123456"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_REGION="us-east-1"

# Azure standard environment variables
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="secret-value"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
```

Or authenticate via CLI credentials (`aws configure` or `az login`).
