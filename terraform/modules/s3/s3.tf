
resource "aws_s3_bucket" "static_website" {
  bucket = ""



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
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "index.html"
  source = "index.html"
  acl    = "public-read"
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "error.html"
  source = "error.html" # 需要将 error.html 文件放在当前目录
  acl    = "public-read"
  content_type = "text/html"
}



