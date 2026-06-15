output "role_name" {
  value       = aws_iam_role.this.name
  description = "Nom du role assume par GitHub Actions."
}

output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "ARN du role CI."
}

output "provider_arn" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "ARN du provider OIDC GitHub."
}
