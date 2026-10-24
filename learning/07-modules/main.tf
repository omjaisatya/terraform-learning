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

# Dummy VPC for module demonstration
resource "aws_vpc" "app_network" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "app-network"
  }
}

# Invoking child module for the Web tier
module "web_security_group" {
  source = "./modules/security-group"

  name                = "web-tier-sg"
  description         = "Inbound rules for public web traffic"
  vpc_id              = aws_vpc.app_network.id
  ingress_ports       = [80, 443]
  allowed_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Tier        = "frontend"
    Environment = "production"
  }
}

# Invoking child module for the Database tier
module "db_security_group" {
  source = "./modules/security-group"

  name                = "db-tier-sg"
  description         = "Inbound PostgreSQL access from private subnet only"
  vpc_id              = aws_vpc.app_network.id
  ingress_ports       = [5432]
  allowed_cidr_blocks = ["10.0.0.0/16"]

  tags = {
    Tier        = "database"
    Environment = "production"
  }
}
