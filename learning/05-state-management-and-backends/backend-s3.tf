# Standard AWS S3 Remote Backend Configuration with DynamoDB State Locking

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }

  backend "s3" {
    # Replace with your dedicated globally unique S3 bucket name
    bucket         = "production-terraform-state-company-2026"
    key            = "workloads/app-stack/terraform.tfstate"
    region         = "ap-south-1"

    # Enables state locking via DynamoDB
    dynamodb_table = "terraform-state-locks"

    # Enforces server-side encryption at rest using AWS KMS
    encrypt        = true
  }
}

# Reference infrastructure required to create the backend itself:
# 1. aws_s3_bucket with versioning enabled:
#    resource "aws_s3_bucket_versioning" "state" {
#      bucket = aws_s3_bucket.state.id
#      versioning_configuration { status = "Enabled" }
#    }
#
# 2. aws_dynamodb_table with LockID partition key:
#    resource "aws_dynamodb_table" "state_locks" {
#      name         = "terraform-state-locks"
#      billing_mode = "PAY_PER_REQUEST"
#      hash_key     = "LockID"
#      attribute {
#        name = "LockID"
#        type = "S"
#      }
#    }
