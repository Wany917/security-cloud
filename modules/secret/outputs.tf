output "arn" {
  value       = aws_secretsmanager_secret.this.arn
  description = "ARN du secret."
}

output "name" {
  value       = aws_secretsmanager_secret.this.name
  description = "Nom du secret."
}

output "id" {
  value       = aws_secretsmanager_secret.this.id
  description = "ID du secret."
}
