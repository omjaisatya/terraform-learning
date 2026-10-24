terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }
  }
  backend "s3" {
    bucket = "s3-bucket-demo-terraform-aaa63e573ac1120e"
    key = "backend.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "webserver" {
  ami = "ami-07a00cf47dbbc844c"
  instance_type = "t3.micro"

  tags = {
    Name = "ExampleInstance"
  }
}