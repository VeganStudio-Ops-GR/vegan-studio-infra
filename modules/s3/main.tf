resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.project_name}-code-artifacts-${var.env}" # Must be unique globally

  force_destroy = true # Allows deleting bucket even if it has files (for lab safety)

  tags = {
    Name = "${var.project_name}-artifact-bucket"
  }
}

# Block all public access (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "app_bucket_acl" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
