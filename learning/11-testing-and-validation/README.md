# Module 11: Native Testing and Validation

## The Terraform Test Framework (`terraform test`)

Starting with Terraform 1.6, HashiCorp introduced native testing into the CLI. Tests are written directly in HCL inside files ending in `.tftest.hcl` located in the root directory or a `tests/` subdirectory.

The test framework replaces the need for third-party tools like Terratest for standard validation logic.

## Types of Tests in Terraform

1. **Unit / Syntactic Tests (`command = plan`)**:
   Runs a plan against the configuration, validates calculated attributes, and asserts business logic without creating real infrastructure. Fast and incurs zero cloud cost.

2. **Integration Tests (`command = apply`)**:
   Creates temporary infrastructure in an isolated test account, verifies behavior and live outputs against assertions, and automatically destroys the test infrastructure when the test completes.

## Anatomy of a `.tftest.hcl` File

A test file consists of one or more sequential `run` blocks:

```hcl
run "verify_bucket_naming_rule" {
  command = plan # or apply

  variables {
    environment = "dev"
    bucket_name = "corp-data-dev"
  }

  assert {
    condition     = aws_s3_bucket.storage.bucket == "corp-data-dev"
    error_message = "S3 bucket name does not match expected naming convention"
  }

  assert {
    condition     = can(regex("^corp-", aws_s3_bucket.storage.bucket))
    error_message = "Bucket name must start with 'corp-'"
  }
}
```

## Running Tests

Execute all tests in the current module:

```bash
terraform test
```

Target a specific test file:

```bash
terraform test -test-directory=tests -filter=tests/unit_test.tftest.hcl
```

Verbose test output with variable details:

```bash
terraform test -verbose
```

## Mocking Providers (Terraform 1.7+)

In CI/CD environments where cloud credentials should not be exposed on pull request checks, you can mock provider responses:

```bash
# Evaluates configurations without contacting AWS/Azure APIs
terraform test -mock-provider=aws
```
