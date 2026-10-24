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

resource "aws_s3_bucket" "tfProject-bucket" {
  bucket = "tf-project-${random_id.genRandom.hex}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.tfProject-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "tf-project" {
  bucket = aws_s3_bucket.tfProject-bucket.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid       = "PublicReadGetObject",
          Effect    = "Allow",
          Principal = "*",
          Action    = "s3:GetObject"
          Resource  = "arn:aws:s3:::${aws_s3_bucket.tfProject-bucket.id}/*"

        }
      ]
    }
  )
}

resource "aws_s3_bucket_website_configuration" "tfProject" {
  bucket = aws_s3_bucket.tfProject-bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.tfProject-bucket.bucket
  source       = "./index.html"
  key          = "index.html"
  content_type = "text/html"
}
