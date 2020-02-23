output "table_name" {
  value       = join("", aws_dynamodb_table.onica.*.name)
  description = "DynamoDB table name"
}

output "table_id" {
  value       = join("", aws_dynamodb_table.onica.*.id)
  description = "DynamoDB table ID"
}

output "table_arn" {
  value       = join("", aws_dynamodb_table.onica.*.arn)
  description = "DynamoDB table ARN"
}