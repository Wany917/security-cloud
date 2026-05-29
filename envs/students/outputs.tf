output "kms_sops_key_arn" {
  value       = module.kms_sops.key_arn
  description = "ARN de la cle KMS pour SOPS. A copier dans .sops.yaml."
}

output "kms_sops_alias" {
  value       = module.kms_sops.alias_name
  description = "Alias humain-lisible de la cle SOPS."
}

output "kms_cloudtrail_key_arn" {
  value       = module.kms_cloudtrail.key_arn
  description = "ARN de la cle KMS qui chiffre les logs CloudTrail."
}

output "sops_user_name" {
  value       = aws_iam_user.sops.name
  description = "Nom du user IAM qui utilise SOPS."
}

output "sops_user_access_key_id" {
  value       = aws_iam_access_key.sops.id
  description = "Access key ID pour le user SOPS. A stocker dans un coffre, pas dans git."
  sensitive   = true
}

output "sops_user_secret_access_key" {
  value       = aws_iam_access_key.sops.secret
  description = "Secret access key du user SOPS."
  sensitive   = true
}

output "cloudtrail_name" {
  value       = aws_cloudtrail.audit.name
  description = "Nom du trail CloudTrail (importe puis hardene)."
}

output "cloudtrail_bucket" {
  value       = aws_s3_bucket.cloudtrail.id
  description = "Bucket S3 destination des logs CloudTrail."
}

output "analyst_user_name" {
  value       = aws_iam_user.analyst.name
  description = "Nom du user analyst avec permissions boundary."
}

output "analyst_permissions_boundary_arn" {
  value       = aws_iam_policy.analyst_permissions_boundary.arn
  description = "ARN de la permissions boundary appliquee a l'analyst."
}

# ── Reseau ──
output "vpc_id" {
  value       = module.network.vpc_id
  description = "ID du VPC zero-trust."
}

output "public_subnet_id" {
  value       = module.network.public_subnet_id
  description = "ID du subnet public."
}

output "private_subnet_id" {
  value       = module.network.private_subnet_id
  description = "ID du subnet prive."
}

output "web_sg_id" {
  value       = module.security_groups.web_sg_id
  description = "ID du security group web."
}

output "db_sg_id" {
  value       = module.security_groups.db_sg_id
  description = "ID du security group base de donnees."
}

# ── Logging ──
output "vpc_flow_log_group" {
  value       = module.logging.log_group_name
  description = "Log group CloudWatch des VPC flow logs."
}

output "kms_logs_key_arn" {
  value       = module.kms_logs.key_arn
  description = "ARN de la cle KMS des flow logs."
}

output "logs_archive_bucket" {
  value       = module.logs_export.archive_bucket
  description = "Bucket S3 d'archivage des logs CloudWatch (via Firehose)."
}

# ── IAM / Secrets ──
output "secretsreader_role_arn" {
  value       = module.iam_secretsreader.role_arn
  description = "ARN du role EC2 secretsreader."
}

output "secretsreader_instance_profile" {
  value       = module.iam_secretsreader.instance_profile_name
  description = "Instance profile du role secretsreader."
}

output "fyc_db_secret_arn" {
  value       = aws_secretsmanager_secret.fyc_db.arn
  description = "ARN du secret BDD repris en IaC."
}

# ── EC2 demo ──
output "demo_instance_id" {
  value       = module.ec2_web.instance_id
  description = "ID de l'instance demo IMDSv2 (null si non deployee)."
}
