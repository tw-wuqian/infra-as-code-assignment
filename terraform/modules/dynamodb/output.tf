output "table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "table_name" {
  value = aws_dynamodb_table.users.name
}
