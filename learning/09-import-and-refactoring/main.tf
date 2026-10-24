terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Example 1: Declarative import block (Terraform 1.5+)
# Instructs Terraform to import an unmanaged S3 bucket into the declared resource address
import {
  to = aws_s3_bucket.migrated_assets
  id = "company-legacy-assets-bucket"
}

# The target resource definition (can be manually declared or generated with -generate-config-out)
resource "aws_s3_bucket" "migrated_assets" {
  bucket = "company-legacy-assets-bucket"

  tags = {
    Environment = "production"
    ImportedBy  = "terraform"
  }
}

# Example 2: Refactoring with moved block
# Safely renames resource 'aws_instance.old_webserver' to 'aws_instance.webserver'
# without triggering a destroy-and-recreate cycle in production.
moved {
  from = aws_instance.old_webserver
  to   = aws_instance.webserver
}

resource "aws_instance" "webserver" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "t3.micro"

  tags = {
    Name = "refactored-webserver"
  }
}
