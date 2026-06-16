# ──────────────────────────────────────────────────────────────────────────
# Bonus etape 3 : export canonique CloudWatch Logs -> Firehose -> S3.
# Gate (off par defaut) : Firehose n'est dispo qu'apres upgrade du compte
# (sinon SubscriptionRequiredException). On exporte le log group CloudTrail.
# ──────────────────────────────────────────────────────────────────────────

module "firehose_export" {
  count  = var.enable_firehose_export ? 1 : 0
  source = "../../modules/firehose-export"

  name_prefix           = var.project_name
  source_log_group_name = module.alerting.trail_log_group_name
  region                = var.region
  kms_admin_arns        = [local.caller_arn]
  access_log_bucket     = module.s3_access_logs.bucket
}
