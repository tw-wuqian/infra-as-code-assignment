
resource "aws_s3_bucket" "static_website" {
  bucket = "iam-new"

  tags = {
    Name        = "StaticWebsiteBucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_website.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::***:role/jijun-assign-github-actions-role"
        },
        "Action": "s3:PutBucketPolicy",
        "Resource": "arn:aws:s3:::iam-new"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "index.html"
  source = "./index.html"
  acl    = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "error.html"
  source = "./error.html"
  acl    = "public-read"
  content_type = "text/html"
}



