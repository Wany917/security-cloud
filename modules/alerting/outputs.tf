output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "ARN du topic SNS des alertes de securite."
}

output "trail_log_group_arn" {
  value       = aws_cloudwatch_log_group.trail.arn
  description = "ARN du log group CloudWatch qui recoit les events CloudTrail."
}

output "trail_log_group_name" {
  value       = aws_cloudwatch_log_group.trail.name
  description = "Nom du log group CloudTrail."
}

output "cloudtrail_cw_role_arn" {
  value       = aws_iam_role.trail_cw.arn
  description = "ARN du role assume par CloudTrail pour ecrire dans CloudWatch Logs."
}

output "alarm_names" {
  value       = [for a in aws_cloudwatch_metric_alarm.this : a.alarm_name]
  description = "Liste des alarmes de securite creees."
}
