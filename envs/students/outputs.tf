# ── Secrets (SOPS) ──
output "kms_sops_key_arn" {
  value       = module.sops.kms_key_arn
  description = "ARN de la cle KMS pour SOPS. A copier dans .sops.yaml."
}

output "kms_sops_alias" {
  value       = module.sops.kms_alias
  description = "Alias humain-lisible de la cle SOPS."
}

output "sops_user_name" {
  value       = module.sops.user_name
  description = "Nom du user IAM qui utilise SOPS."
}

output "sops_user_access_key_id" {
  value       = module.sops.access_key_id
  description = "Access key ID pour le user SOPS. A stocker dans un coffre, pas dans git."
  sensitive   = true
}

output "sops_user_secret_access_key" {
  value       = module.sops.secret_access_key
  description = "Secret access key du user SOPS."
  sensitive   = true
}

# ── CloudTrail ──
output "kms_cloudtrail_key_arn" {
  value       = module.cloudtrail.kms_key_arn
  description = "ARN de la cle KMS qui chiffre les logs CloudTrail."
}

output "cloudtrail_name" {
  value       = module.cloudtrail.trail_name
  description = "Nom du trail CloudTrail."
}

output "cloudtrail_bucket" {
  value       = module.cloudtrail.bucket
  description = "Bucket S3 destination des logs CloudTrail."
}

# ── IAM ──
output "analyst_user_name" {
  value       = module.iam.analyst_user_name
  description = "Nom du user analyst avec permissions boundary."
}

output "analyst_permissions_boundary_arn" {
  value       = module.iam.analyst_permissions_boundary_arn
  description = "ARN de la permissions boundary appliquee a l'analyst."
}

output "secretsreader_role_arn" {
  value       = module.iam.role_arn
  description = "ARN du role EC2 secretsreader."
}

output "secretsreader_instance_profile" {
  value       = module.iam.instance_profile_name
  description = "Instance profile du role secretsreader."
}

output "fyc_db_secret_arn" {
  value       = aws_secretsmanager_secret.fyc_db.arn
  description = "ARN du secret BDD repris en IaC."
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
  description = "Bucket S3 d'archivage des logs reseau."
}

# ── EC2 demo ──
output "demo_instance_id" {
  value       = module.ec2_web.instance_id
  description = "ID de l'instance demo IMDSv2 (null si non deployee)."
}
