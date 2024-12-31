
resource "aws_s3_bucket" "static_website" {
  bucket = "jijun-s3"

  tags = {
    Name        = "StaticWebsiteBucket"
    Environment = "Production"
  }

}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_website.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::160071257600:role/jijun-assign-github-actions-role"
        },
        Action   = "s3:PutBucketPolicy",
        Resource = "arn:aws:s3:::jijun-s3"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "index.html"
  source = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "error.html"
  source = "${path.module}/error.html"
  content_type = "text/html"
}



