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

resource "aws_instance" "webserver" {
  ami           = "ami-07a00cf47dbbc844c"
  instance_type = "t3.micro"

  tags = {
    Name = "ExampleInstance"
  }
}