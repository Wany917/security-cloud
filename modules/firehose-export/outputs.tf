output "delivery_stream_arn" {
  value       = aws_kinesis_firehose_delivery_stream.this.arn
  description = "ARN du delivery stream Firehose."
}

output "bucket" {
  value       = aws_s3_bucket.this.id
  description = "Bucket S3 de destination de l'export."
}

output "kms_key_arn" {
  value       = module.kms.key_arn
  description = "ARN de la cle KMS de l'export."
}
