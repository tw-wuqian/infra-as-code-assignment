data "aws_s3_bucket" "existing" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_object" "upload_files" {
  for_each = {
    "index.html" = "./index.html"
    "error.html" = "./error.html"
  }

  bucket = data.aws_s3_bucket.existing.id
  key    = each.key
  source = each.value
  acl    = "public-read"
}
