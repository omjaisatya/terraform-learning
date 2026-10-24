# Native Terraform Test File (Terraform 1.6+)

# Test Run 1: Verify default dev identifier generation in plan mode
run "validate_dev_defaults" {
  command = plan

  assert {
    condition     = output.computed_identifier == "auth-service-dev"
    error_message = "Computed identifier should match auth-service-dev by default"
  }
}

# Test Run 2: Verify custom prod environment variable override
run "validate_prod_environment_override" {
  command = plan

  variables {
    environment  = "prod"
    service_name = "payment-gateway"
  }

  assert {
    condition     = output.computed_identifier == "payment-gateway-prod"
    error_message = "Computed identifier failed to construct payment-gateway-prod"
  }

  assert {
    condition     = endswith(output.artifact_path, "payment-gateway-prod.json")
    error_message = "Artifact filename must end with payment-gateway-prod.json"
  }
}
