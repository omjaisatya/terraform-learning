terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_db_instance" "postgres_db" {
  identifier        = "my-postgres-db"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"

  username = var.db_username
  password = var.db_password
  db_name  = "tfdb"

  publicly_accessible = true
  skip_final_snapshot = true

  backup_retention_period = 7

  tags = {
    Name        = "TerraformPostgresDB"
    Environment = "dev"
  }
}
