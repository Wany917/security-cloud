output "bucket" {
  value       = aws_s3_bucket.state.id
  description = "Nom du bucket de state."
}

output "bucket_arn" {
  value       = aws_s3_bucket.state.arn
  description = "ARN du bucket de state."
}

output "table_name" {
  value       = aws_dynamodb_table.lock.name
  description = "Nom de la table de verrou."
}

output "table_arn" {
  value       = aws_dynamodb_table.lock.arn
  description = "ARN de la table de verrou."
}
