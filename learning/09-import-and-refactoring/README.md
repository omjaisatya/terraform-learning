# Module 09: Import and Refactoring

## Managing Existing Infrastructure (Terraform Import)

When teams adopt Terraform, they often have existing cloud resources created manually via the console or CLI. Terraform import brings these pre-existing resources into state management.

## 1. Legacy CLI Import (`terraform import`)

In Terraform versions prior to 1.5, importing required two manual steps:

1. Write an empty or partial resource block in your HCL code:

   ```hcl
   resource "aws_s3_bucket" "my_bucket" {
     # Must match the cloud resource attributes manually
   }
   ```

2. Execute the CLI command with the cloud identifier:

   ```bash
   terraform import aws_s3_bucket.my_bucket my-existing-bucket-name
   ```

**Limitations**: The CLI command immediately modifies the state file without a plan/preview step. If the written HCL did not match cloud attributes, running the next `apply` could accidentally destroy or modify the imported resource.

## 2. Modern Declarative `import` Blocks (Terraform 1.5+)

Starting with Terraform 1.5, import became a first-class declarative construct in HCL.

### Syntax

```hcl
import {
  to = aws_s3_bucket.imported_storage
  id = "existing-production-bucket-name"
}
```

- `to`: The target resource address in your Terraform configuration.
- `id`: The cloud provider's resource identifier (e.g., S3 bucket name, EC2 instance ID `i-123456`, or Azure Resource ID).

### Automatic Configuration Generation

Instead of writing the HCL code by hand, you can instruct Terraform to generate it for you:

```bash
terraform plan -generate-config-out=generated_resources.tf
```

Terraform queries the cloud provider, inspects the resource with the specified `id`, and writes compliant HCL blocks directly into `generated_resources.tf`.

You then review the generated HCL, adjust variable references, and run:

```bash
terraform apply
```

Once applied, the import block has done its job and can either be retained for documentation or removed.

## 3. Refactoring Code without Destruction (`moved` Blocks)

If you rename a resource block or move it into a child module, Terraform normally treats this as:

1. Destroy the old resource address.
2. Create a new resource at the new address.

For databases, storage, and networking, destroying live resources causes catastrophic data loss and downtime.

Use `moved` blocks (introduced in Terraform 1.1) to inform Terraform that a resource address changed:

```hcl
# Informs Terraform that 'aws_instance.legacy_web' is now 'aws_instance.web'
moved {
  from = aws_instance.legacy_web
  to   = aws_instance.web
}
```

### Moving Resources into Child Modules

```hcl
# Informs Terraform that a root resource was refactored into module.networking
moved {
  from = aws_security_group.firewall
  to   = module.networking.aws_security_group.firewall
}
```

When you run `terraform plan`, Terraform recognizes the move and updates the state file mapping without touching the live cloud resource:

```txt
Plan: 0 to add, 0 to change, 0 to destroy.
```

*(With a notification indicating that the resource has moved addresses)*.
