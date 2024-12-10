resource "aws_s3_bucket" "example" {
  bucket = "wei-bucket-1"

  tags = {
    Name        = "wei bucket"
    Environment = "Dev"
  }
}