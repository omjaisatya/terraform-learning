# Module 03: Resources and Meta-Arguments

## Resource Anatomy

A resource block declares a resource of a given type with a given local name:

```hcl
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow inbound HTTP"
  vpc_id      = aws_vpc.main.id
}
```

- Type: `aws_security_group`
- Local Name: `web_sg`
- Unique Address: `aws_security_group.web_sg`

Within the same module, the type and name pair must be unique.

## Meta-Arguments

Meta-arguments are special arguments built into Terraform that can be used inside any resource block to change how Terraform manages that resource.

### 1. `depends_on`

Specifies explicit dependencies. While Terraform automatically handles dependencies based on reference attributes, you must use `depends_on` when a dependency exists outside of direct data references (e.g., an IAM policy assignment must exist before an S3 bucket or Lambda function can operate).

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "company-audit-logs-2026"
  depends_on = [
    aws_iam_role_policy_attachment.s3_write_policy
  ]
}
```

### 2. `count`

Creates multiple instances of a resource using a whole number. Inside the block, `count.index` provides the current zero-based index.

```hcl
resource "aws_instance" "workers" {
  count         = 3
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  tags = {
    Name = "worker-${count.index}"
  }
}
```

**The Count Pitfall**:
`count` addresses resources by index array: `aws_instance.workers[0]`, `aws_instance.workers[1]`, `aws_instance.workers[2]`.
If you remove an element from the middle of a list driving `count`, Terraform shifts all subsequent indices down by 1. This causes unnecessary recreations (destroys and recreates resources that didn't actually change).

### 3. `for_each`

Creates multiple instances keyed by map keys or set strings. Each instance is identified by its key rather than an integer index (`aws_instance.workers["api"]`, `aws_instance.workers["web"]`).

Inside the block:

- `each.key`: The map key or set string.
- `each.value`: The map value or set item.

```hcl
variable "subnets" {
  type = map(string)
  default = {
    "public-a"  = "10.0.1.0/24"
    "public-b"  = "10.0.2.0/24"
    "private-a" = "10.0.10.0/24"
  }
}

resource "aws_subnet" "managed" {
  for_each   = var.subnets
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value

  tags = {
    Name = each.key
  }
}
```

**Why `for_each` is preferred**: Adding, removing, or reordering elements in a map does not disrupt unaffected resources.

### 4. `provider`

Directs Terraform to use a specific provider configuration alias rather than the default provider.

```hcl
resource "aws_s3_bucket" "backup" {
  provider = aws.singapore
  bucket   = "dr-backup-bucket-singapore"
}
```

### 5. `lifecycle` Block

Customizes lifecycle rules for resources during plan and apply:

- `create_before_destroy = true`:
  Terraform creates the replacement resource before destroying the existing one. Crucial for zero-downtime rolling updates on servers, launch configurations, and SSL certificates.

- `prevent_destroy = true`:
  Terraform rejects any plan that would destroy the resource. Protects critical production databases, S3 buckets, and primary networking components from accidental deletions.

- `ignore_changes = [ ... ]`:
  Instructs Terraform to ignore changes to specified attributes made out-of-band (e.g., autoscaling groups updating `desired_capacity`, or an automated tagger adding compliance tags).
  Can ignore all attributes using `ignore_changes = all`.

- `replace_triggered_by = [ ... ]`:
  Forces resource replacement if a referenced attribute or resource changes (e.g., replace an EC2 instance whenever a launch template or user-data file hash updates).

```hcl
resource "aws_instance" "app" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes = [
      tags["LastUpdated"]
    ]
    replace_triggered_by = [
      aws_security_group.app_sg.id
    ]
  }
}
```

### 6. Custom Conditions: `precondition` and `postcondition`

Added inside `lifecycle` blocks to assert guarantees before creating or after creating resources:

```hcl
resource "aws_instance" "compliant_vm" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  lifecycle {
    postcondition {
      condition     = self.public_dns != ""
      error_message = "The instance must have a valid public DNS assigned."
    }
  }
}
```
