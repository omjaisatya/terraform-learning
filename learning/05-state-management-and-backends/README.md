# Module 05: State Management and Remote Backends

## What is Terraform State?

Terraform state (`terraform.tfstate`) is a JSON file that maps your declarative HCL configuration to real-world cloud resources.

When you declare:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t3.micro"
}
```

AWS doesn't know that this server belongs to `aws_instance.web`. Terraform assigns a physical ID (such as `i-0a1b2c3d4e5f`) and stores that mapping in the state file.

## Why Terraform Needs State

1. **Mapping Configuration to Real Infrastructure**: Tracks which cloud resources correspond to which HCL blocks.
2. **Metadata Tracking**: Records resource dependencies, provider pointers, and metadata that cloud APIs do not retain.
3. **Performance Optimization**: Caches resource attributes locally so Terraform doesn't have to query hundreds of cloud API endpoints every time you inspect your configuration.
4. **Concurrency and Collaboration**: Locks infrastructure modifications so two engineers or CI/CD pipelines cannot run `terraform apply` concurrently.

## Anatomy of the State File

A `terraform.tfstate` file contains:

- `version`: State format version schema.
- `terraform_version`: The binary version that wrote the state.
- `serial`: Integer counter incremented every time the state is modified. If two applies try to commit with the same serial, a collision occurs.
- `lineage`: A unique UUID generated when the state was first initialized. Ensures two different projects cannot overwrite each other.
- `resources`: Array of all managed resources, data sources, and their real-world attributes (including IP addresses, ARNs, sensitive keys, and passwords).

## Dangers of Local State

Storing `terraform.tfstate` locally on your laptop causes severe problems:

- **No Locking**: Two teammates applying changes simultaneously will corrupt the state file or overwrite each other's resources.
- **Data Loss**: If your laptop fails or you delete the directory, Terraform loses tracking of all live cloud resources.
- **Security Leaks**: The state file stores sensitive values (database passwords, private keys, connection strings) in **unencrypted plain text**. Pushing `.tfstate` to Git exposes credentials publicly.

## Remote Backends

A remote backend stores the state file in a shared, durable, encrypted object store with automated distributed locking.

### 1. AWS S3 + DynamoDB Backend

- **Storage**: AWS S3 bucket with versioning enabled and default SSE-KMS encryption.
- **Locking**: AWS DynamoDB table with a primary key named `LockID` (String).
- When a run begins, Terraform acquires a lease in DynamoDB. Other runs are blocked until the lock is released.

### 2. Azure Blob Storage Backend

- **Storage**: Azure Blob Container in a Storage Account.
- **Locking**: Native Azure Blob Lease mechanism (no extra database required).

## State CLI Commands

Never edit `terraform.tfstate` by hand with a text editor. Use the dedicated CLI commands:

### terraform state list

Lists all resource addresses recorded in the state file.

```bash
terraform state list
# Example output:
# aws_vpc.main
# aws_subnet.public["a"]
# aws_instance.webserver[0]
```

### terraform state show

Displays all recorded attributes for a single resource address.

```bash
terraform state show aws_instance.webserver[0]
```

### terraform state mv

Renames a resource in the state without destroying and recreating it in the cloud.

```bash
# Rename within the same configuration
terraform state mv aws_instance.old_name aws_instance.new_name

# Move a resource into a child module
terraform state mv aws_security_group.app module.network.aws_security_group.app
```

### terraform state rm

Removes a resource from state tracking without deleting it from the cloud.
Useful when adopting existing resources or decoupling resources from Terraform management.

```bash
terraform state rm aws_s3_bucket.legacy_data
```

### terraform state pull & terraform state push

Used for disaster recovery and backend migrations.

```bash
# Download remote state to standard output
terraform state pull > state_backup.json

# Overwrite remote state (requires extreme caution)
terraform state push state_backup.json
```

### terraform force-unlock

Releases a stuck state lock if a CI/CD job crashed without unlocking the table.

```bash
terraform force-unlock <LOCK_ID>
```

## State Drift and Reconciliation

Drift occurs when infrastructure is modified directly in the cloud console or via CLI outside of Terraform.

To inspect drift without modifying cloud resources:

```bash
terraform plan -refresh-only
```

To update your state file to reflect real cloud reality without reverting changes:

```bash
terraform apply -refresh-only
```

## Cross-Stack State Sharing (`terraform_remote_state`)

Allows one Terraform workspace to read outputs exported by another workspace (for example, an application stack reading VPC IDs and subnet IDs from a networking stack).

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "mycompany-terraform-states"
    key    = "networking/production.tfstate"
    region = "ap-south-1"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
}
```
