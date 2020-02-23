output "name" {
  value       = "${join("", aws_iam_role.LambdaDynamoAPICloudWatch.*.name)}"
  description = "The name of the IAM role created"
}

output "id" {
  value       = "${join("", aws_iam_role.LambdaDynamoAPICloudWatch.*.unique_id)}"
  description = "The stable and unique string identifying the role"
}

output "arn" {
  value       = "${join("", aws_iam_role.LambdaDynamoAPICloudWatch.*.arn)}"
  description = "The Amazon Resource Name (ARN) specifying the role"
}