# ──────────────────────────────────────────────────────────────────────────
# Partie 3 : archivage des logs reseau dans S3
# Les flow logs vont vers CloudWatch (module logging, pour l'alerting temps reel)
# ET directement vers S3 (ce module, pour l'archivage durable).
# ──────────────────────────────────────────────────────────────────────────

module "logs_export" {
  source = "../../modules/logs-archive"

  name_prefix           = var.project_name
  vpc_id                = module.network.vpc_id
  account_id            = local.account_id
  kms_admin_arns        = [local.caller_arn]
  enable_access_logging = true
  access_log_bucket     = module.s3_access_logs.bucket
}
