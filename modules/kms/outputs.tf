output "key_id" {
  value       = aws_kms_key.cmk.key_id
  description = "ID de la cle KMS."
}

output "key_arn" {
  value       = aws_kms_key.cmk.arn
  description = "ARN de la cle KMS (a referencer dans .sops.yaml)."
}

output "alias_name" {
  value       = aws_kms_alias.cmk.name
  description = "Nom complet de l'alias (alias/...)."
}

output "alias_arn" {
  value       = aws_kms_alias.cmk.arn
  description = "ARN de l'alias KMS."
}
