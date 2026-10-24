terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "random_id" "genRandom" {
    byte_length = 8
}

resource "aws_s3_bucket" "demo-bucket" {
  bucket = "s3-bucket-demo-terraform-${random_id.genRandom.hex}"
}

resource "aws_s3_object" "bucket-data" {
    bucket = aws_s3_bucket.demo-bucket.bucket
    source = "./myfile.txt"
    key    = "myfile.txt"
}