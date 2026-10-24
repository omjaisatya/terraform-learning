# Module 12: Security Best Practices and CI/CD Automation

## Terraform Security Checklist

Infrastructure as Code has full administrative privileges over your cloud estate. A single vulnerability in your repository can compromise databases, storage, and networking.

### 1. Eliminating Hardcoded Secrets

- Never commit AWS access keys, Azure client secrets, or database passwords in `.tf` files.
- Mark sensitive input variables and outputs with `sensitive = true` to suppress console output.
- Retrieve runtime secrets dynamically using dedicated secret managers:
  - AWS Secrets Manager (`aws_secretsmanager_secret_version`)
  - AWS SSM Parameter Store (`aws_ssm_parameter`)
  - HashiCorp Vault (`vault_generic_secret`)
  - Azure Key Vault (`azurerm_key_vault_secret`)

Example reading database credentials dynamically from AWS Secrets Manager:

```hcl
data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "production/database/master_credentials"
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)
}

resource "aws_db_instance" "app_db" {
  username = local.db_credentials.username
  password = local.db_credentials.password
}
```

### 2. Protecting the State File

- **Marking an attribute `sensitive = true` does NOT encrypt it in `terraform.tfstate`**. It only hides it from CLI output. The raw password is still saved in plain text in the state file.
- Remote backends (S3, Azure Blob) MUST enforce:
  - Encryption at rest via KMS or customer-managed keys.
  - Enforced TLS (`aws:SecureTransport`) in bucket policies.
  - Strict IAM permissions allowing only CI/CD runners to read the state bucket.
  - S3 bucket versioning enabled to prevent accidental deletion or corruption.

### 3. Static Analysis and Security Linting

Integrate these static scanners into pre-commit hooks and CI/CD pipelines:

1. **tflint**:
   Detects provider-specific configuration errors, invalid instance types, and deprecated syntax.

   ```bash
   tflint --init
   tflint
   ```

2. **tfsec / trivy**:
   Scans HCL code for cloud security misconfigurations (such as open security groups, unencrypted EBS volumes, public S3 buckets).

   ```bash
   trivy config ./
   ```

3. **checkov**:
   Policy-as-code enforcement tool for compliance (CIS Benchmark, HIPAA, SOC 2, PCI-DSS).

   ```bash
   checkov -d .
   ```

## Production CI/CD Pipeline Architecture

Terraform deployments in enterprise teams should be automated through GitOps:

1. **Pull Request Stage**:
   - Run `terraform fmt -check` (fails if code is not formatted).
   - Run `terraform validate` (validates syntax).
   - Run security scanner (`trivy` or `checkov`).
   - Run `terraform plan` and comment the plan output directly onto the GitHub PR for peer review.
2. **Merge to Main Stage**:
   - Automatically run `terraform apply -auto-approve` using isolated CI/CD IAM credentials.
   - Lock deployment concurrency to prevent overlapping runs.
