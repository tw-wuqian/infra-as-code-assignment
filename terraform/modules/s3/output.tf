# 输出 S3 网站托管 URL
output "website_url" {
  value = aws_s3_bucket.static_website.website_endpoint
}
