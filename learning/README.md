# Terraform Learning

This guide covers all core, intermediate, and advanced Terraform concepts with production-ready HCL code examples. Each directory contains dedicated documentation and runnable Terraform configuration files.

## Table of Contents

1. [Basics and Architecture](01-basics-and-architecture/README.md)
   - Infrastructure as Code (IaC) principles
   - Core vs Provider plugin architecture and gRPC communication
   - Declarative configuration model and dependency graph (DAG)
   - Complete CLI command reference

2. [Providers and Versions](02-providers-and-versions/README.md)
   - Provider declarations, sources, and registry namespaces
   - Version constraint syntax and pinning best practices
   - Provider aliases for multi-region and multi-account deployments
   - Authentication methods and plugin cache optimization

3. [Resources and Meta-Arguments](03-resources-and-meta-arguments/README.md)
   - Resource syntax, addressing, and behavior
   - Meta-arguments: `depends_on`, `count`, `for_each`, `provider`
   - Lifecycle block: `create_before_destroy`, `prevent_destroy`, `ignore_changes`, `replace_triggered_by`
   - Count vs For-Each evaluation trade-offs

4. [Variables, Outputs, and Locals](04-variables-outputs-and-locals/README.md)
   - Variable types: primitives, collections, structural types
   - Custom validation rules and error conditions
   - Output definitions, sensitive flags, and dependency tracking
   - Local values (`locals`) vs input variables
   - Variable definition precedence rules

5. [State Management and Backends](05-state-management-and-backends/README.md)
   - How `terraform.tfstate` maps configuration to real-world resources
   - Concurrency, locking mechanisms, and state corruption prevention
   - S3 + DynamoDB and Azure Blob remote backend configurations
   - State CLI commands: `list`, `show`, `mv`, `rm`, `pull`, `push`, `force-unlock`
   - State drift detection and refresh workflows
   - Cross-stack state sharing with `terraform_remote_state`

6. [Expressions, Functions, and Loops](06-expressions-functions-and-loops/README.md)
   - Conditionals and ternary expressions
   - `for` expressions with filtering and grouping
   - Built-in functions: string, collection, encoding, filesystem, IP network
   - Dynamic blocks for repeating nested resource structures
   - External file template rendering with `templatefile`

7. [Modules](07-modules/README.md)
   - Root vs child modules
   - Module sources: local directories, Git repositories, Terraform Registry
   - Input/output contracts and passing providers to child modules
   - Standard module directory layout and reusability patterns

8. [Provisioners and Null Resources](08-provisioners-and-null-resources/README.md)
   - `local-exec`, `remote-exec`, and `file` provisioners
   - Connection blocks (SSH and WinRM)
   - Creation-time vs destroy-time provisioners and failure handling
   - Modern alternative: `terraform_data` resource and cloud-init

9. [Import and Refactoring](09-import-and-refactoring/README.md)
   - CLI import command syntax
   - Native HCL `import` blocks (Terraform 1.5+)
   - Automatic configuration generation (`-generate-config-out`)
   - Resource renaming and refactoring without destruction via `moved` blocks

10. [Workspaces and Environments](10-workspaces-and-environments/README.md)
    - CLI workspaces: `new`, `select`, `list`, `show`, `delete`
    - Dynamic configuration with `${terraform.workspace}`
    - CLI workspaces vs directory-based environment separation

11. [Testing and Validation](11-testing-and-validation/README.md)
    - Native `terraform test` framework (Terraform 1.6+)
    - Test files (`.tftest.hcl`), run blocks, and assertions
    - Mocking providers and dry-run validation

12. [Security Best Practices and CI/CD](12-security-best-practices-and-cicd/README.md)
    - Managing secrets without code leaks (HashiCorp Vault, AWS SSM, env vars)
    - Static analysis and security scanning (tflint, tfsec, checkov)
    - Production GitHub Actions pipeline for plan and apply
