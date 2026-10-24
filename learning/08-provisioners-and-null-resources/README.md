# Module 08: Provisioners and Null Resources

## What are Provisioners?

Provisioners are used to execute scripts or shell commands either on the local machine executing Terraform (`local-exec`) or on a remote server created by Terraform (`remote-exec` / `file`).

## Why Provisioners are a Last Resort

HashiCorp explicitly recommends against provisioners for standard operations. Reasons include:

1. **Non-Declarative**: Terraform can see the return code of the script, but it cannot model or track the actions taken inside the VM.
2. **State Blindness**: If someone manually modifies or deletes a file created by a provisioner, Terraform cannot detect drift.
3. **Tainted Resources on Failure**: If a creation-time provisioner fails, Terraform marks the parent resource as tainted. On the next `apply`, the resource is destroyed and recreated.
4. **Network & Credential Fragility**: `remote-exec` requires direct SSH/WinRM reachability and network routes between the machine running Terraform and the provisioned VM, which often fails in secure private cloud networks.

**Better Alternatives**:

- Use `user_data` or `cloud-init` scripts for server bootstrapping.
- Use HashiCorp Packer to bake software directly into golden AMIs/images.
- Use AWS Systems Manager (SSM) Run Command or Azure Custom Script Extensions.

## Types of Provisioners

### 1. `local-exec`

Runs commands on the workstation or CI/CD runner executing the Terraform CLI:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "echo Instance ${self.public_ip} created at $(date) >> instances.log"
  }
}
```

### 2. `remote-exec` and `file`

Transfers files and executes commands inside the target machine. Requires an explicit `connection` block:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"
  key_name      = "deployer-key"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "configs/app.conf"
    destination = "/etc/app.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable --now nginx"
    ]
  }
}
```

## Provisioner Settings

- `on_failure = continue`: If the script returns a non-zero exit code, Terraform ignores the error and continues without tainting the resource. Default is `fail`.
- `when = destroy`: Runs the command when the resource is being destroyed (useful for cleanups, such as revoking a license key or de-registering from an external monitoring system).

## Modern Alternative: `terraform_data`

In older Terraform versions, engineers relied on the `null_resource` provider to run custom hooks without provisioning real infrastructure.

Starting with **Terraform 1.4**, HashiCorp introduced the built-in `terraform_data` resource. It requires no external provider plugin.

Use cases for `terraform_data`:

- Running local-exec scripts when specific inputs change via `triggers_replace`.
- Storing temporary values across state transitions.

```hcl
resource "terraform_data" "db_migrator" {
  triggers_replace = [
    # Re-run migration script if the migration SQL file hash changes
    filesha256("${path.module}/migrations/schema.sql")
  ]

  provisioner "local-exec" {
    command = "python3 run_migrations.py --file schema.sql"
  }
}
```
