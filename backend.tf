terraform {
  backend "s3" {
    bucket         = "aws-s3-ter-123"
    key = "swetha-terraform/terraform.tfstate"
    region = "us-east-2"
    encrypt        = true
  }
}
