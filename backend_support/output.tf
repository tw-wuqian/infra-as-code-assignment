output "s3_bucket_name" {
  value = aws_s3_bucket.example.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.id
}

output "table_arn" {
  value = aws_dynamodb_table.terraform_locks.arn
}