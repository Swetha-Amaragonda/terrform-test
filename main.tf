resource "aws_s3_bucket" "test_bucket" {
  bucket        = "swetha-terraform-test-123456"
  force_destroy = true
}