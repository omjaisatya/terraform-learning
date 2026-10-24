# Module 01: Basics and Architecture

## Infrastructure as Code (IaC)

Infrastructure as Code is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

Terraform uses a declarative approach. Instead of writing step-by-step scripts that describe how to create a server (imperative), you declare the desired end state of your infrastructure. Terraform calculates the difference between your declared state and the actual infrastructure, then applies only the necessary changes.

## How Terraform Works Under the Hood

Terraform's architecture consists of two main components:

1. **Terraform Core**:
   - Written in Go.
   - Parses configuration files (`.tf` and `.tf.json`) written in HashiCorp Configuration Language (HCL).
   - Reads the current state file (`terraform.tfstate`).
   - Builds a Directed Acyclic Graph (DAG) representing all resources and their dependencies.
   - Calculates execution plans based on differences between the graph, state, and real infrastructure.
   - Communicates with providers over gRPC (remote procedure calls).

2. **Terraform Plugins (Providers)**:
   - Standalone executable binaries written in Go.
   - Each provider acts as a translation bridge between Terraform Core and a specific cloud API (AWS, Azure, GCP, Kubernetes, GitHub, Cloudflare).
   - Providers expose resources (items you create/manage) and data sources (items you read).
   - When you run `terraform init`, Core downloads the required provider binaries into the `.terraform/providers` directory.

```txt
+-------------------------------------------------------------+
|                       Terraform Core                        |
|  - HCL Parser                                               |
|  - State Engine (terraform.tfstate)                         |
|  - Dependency Graph (DAG) Calculator                        |
|  - Plan & Diff Engine                                       |
+-------------------------------------------------------------+
                              |
                     gRPC Protocol Bridge
                              |
        +---------------------+---------------------+
        |                     |                     |
+---------------+     +---------------+     +---------------+
| AWS Provider  |     | Azure Provider|     | Google Cloud  |
|    Binary     |     |    Binary     |     |    Binary     |
+---------------+     +---------------+     +---------------+
        |                     |                     |
     AWS API               Azure API             GCP API
```

## The Dependency Graph (DAG)

Terraform determines resource creation order automatically by analyzing references in your code. If Resource B uses an attribute from Resource A (for example, `subnet_id = aws_subnet.main.id`), Terraform creates Resource A first, then Resource B.

Resources that do not depend on each other are created or modified concurrently (up to 10 parallel operations by default, configurable via the `-parallelism` flag).

## Core CLI Workflow

1. `terraform init`: Initializes the working directory. Downloads provider plugins, configures the backend, and installs child modules. Must be run whenever you add providers or modules, or modify backend settings.
2. `terraform validate`: Verifies syntax and internal consistency of HCL files without calling cloud APIs.
3. `terraform fmt`: Formats all `.tf` files in the directory to adhere to canonical HCL style guidelines.
4. `terraform plan`: Generates an execution plan by comparing your configuration with the state file and reading current cloud resources. Shows what will be added (+), modified (~), or destroyed (-).
5. `terraform apply`: Executes the actions proposed in the plan. Prompts for manual confirmation unless `-auto-approve` is passed. Updates the state file upon completion.
6. `terraform destroy`: Destroys all managed infrastructure declared in the current configuration.

## Files in this Directory

- `main.tf`: A minimal standalone configuration using local and random providers (no cloud credentials required) to test `init`, `plan`, and `apply`.
- `cli-cheat-sheet.md`: Reference guide for day-to-day Terraform CLI commands and debugging options.
