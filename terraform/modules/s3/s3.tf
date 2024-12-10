data "aws_s3_bucket" "existing" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_object" "upload_files" {
  for_each = {
    "index.html" = "path/to/index.html"
    "error.html" = "path/to/error.html"
  }

  bucket = data.aws_s3_bucket.existing.id
  key    = each.key
  source = each.value
  acl    = "public-read"
}
