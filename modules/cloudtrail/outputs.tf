output "trail_name" {
  value       = aws_cloudtrail.audit.name
  description = "Nom du trail CloudTrail."
}

output "bucket" {
  value       = aws_s3_bucket.logs.id
  description = "Bucket S3 des logs CloudTrail."
}

output "kms_key_arn" {
  value       = module.kms.key_arn
  description = "ARN de la cle KMS des logs CloudTrail."
}
