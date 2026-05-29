output "bucket" {
  value       = aws_s3_bucket.this.id
  description = "Nom du bucket de logs d'acces S3."
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "ARN du bucket de logs d'acces S3."
}
