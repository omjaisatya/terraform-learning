# Primary AWS provider configuration for Mumbai region
provider "aws" {
  region = "ap-south-1"
  default_tags {
    tags = {
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}

# Secondary AWS provider configuration for Singapore region (Disaster Recovery)
provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
  default_tags {
    tags = {
      Environment = "disaster-recovery"
      ManagedBy   = "terraform"
    }
  }
}

# VPC created in primary region (ap-south-1)
resource "aws_vpc" "primary_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "primary-vpc-mumbai"
  }
}

# VPC created in disaster recovery region (ap-southeast-1)
resource "aws_vpc" "dr_vpc" {
  provider             = aws.singapore
  cidr_block           = "10.200.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dr-vpc-singapore"
  }
}

output "primary_vpc_id" {
  description = "ID of primary VPC"
  value       = aws_vpc.primary_vpc.id
}

output "dr_vpc_id" {
  description = "ID of DR VPC"
  value       = aws_vpc.dr_vpc.id
}
