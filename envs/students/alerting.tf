# ──────────────────────────────────────────────────────────────────────────
# Step 3 (volet alerting) : metric filters + alarmes CloudWatch -> SNS.
# CloudTrail est livre vers le log group cree ici (voir cloudtrail.tf).
# ──────────────────────────────────────────────────────────────────────────

module "alerting" {
  source = "../../modules/alerting"

  name_prefix         = var.project_name
  account_id          = local.account_id
  kms_key_arn         = module.kms_logs.key_arn
  tfstate_bucket_name = aws_s3_bucket.tfstate.bucket
  alert_email         = var.alert_email
}
