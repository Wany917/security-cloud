output "archive_bucket" {
  value       = aws_s3_bucket.archive.id
  description = "Bucket S3 d'archivage des logs."
}

output "flow_log_id" {
  value       = aws_flow_log.to_s3.id
  description = "ID du flow log livre vers S3."
}

output "kms_key_arn" {
  value       = module.kms_archive.key_arn
  description = "ARN de la cle KMS de l'archive."
}
