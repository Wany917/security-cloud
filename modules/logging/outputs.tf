output "log_group_name" {
  value       = aws_cloudwatch_log_group.flow.name
  description = "Nom du log group CloudWatch des flow logs."
}

output "log_group_arn" {
  value       = aws_cloudwatch_log_group.flow.arn
  description = "ARN du log group CloudWatch des flow logs."
}

output "flow_log_id" {
  value       = aws_flow_log.vpc.id
  description = "ID du flow log VPC."
}

output "flow_log_role_arn" {
  value       = aws_iam_role.flow.arn
  description = "ARN du role IAM utilise par les flow logs."
}
