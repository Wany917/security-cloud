output "user_name" {
  value       = aws_iam_user.sops.name
  description = "Nom du user IAM SOPS."
}

output "access_key_id" {
  value       = aws_iam_access_key.sops.id
  description = "Access key ID du user SOPS."
  sensitive   = true
}

output "secret_access_key" {
  value       = aws_iam_access_key.sops.secret
  description = "Secret access key du user SOPS."
  sensitive   = true
}

output "kms_key_arn" {
  value       = module.kms.key_arn
  description = "ARN de la cle KMS SOPS."
}

output "kms_alias" {
  value       = module.kms.alias_name
  description = "Alias de la cle KMS SOPS."
}
