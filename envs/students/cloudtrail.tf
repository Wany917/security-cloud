# ──────────────────────────────────────────────────────────────────────────
# Step 3 : CloudTrail (audit des appels API) -> S3 chiffre KMS
# ──────────────────────────────────────────────────────────────────────────

module "cloudtrail" {
  source = "../../modules/cloudtrail"

  kms_alias              = "${var.project_name}/cloudtrail"
  bucket_name            = var.cloudtrail_bucket_name
  trail_name             = var.cloudtrail_trail_name
  account_id             = local.account_id
  kms_admin_arns         = [local.caller_arn]
  enable_access_logging  = true
  access_log_bucket      = module.s3_access_logs.bucket
  data_event_bucket_arns = local.data_event_bucket_arns
}

# ── Relocalisation depuis l'env (0 recreation) ──
moved {
  from = module.kms_cloudtrail
  to   = module.cloudtrail.module.kms
}

moved {
  from = aws_s3_bucket.cloudtrail
  to   = module.cloudtrail.aws_s3_bucket.logs
}

moved {
  from = aws_s3_bucket_public_access_block.cloudtrail
  to   = module.cloudtrail.aws_s3_bucket_public_access_block.logs
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.cloudtrail
  to   = module.cloudtrail.aws_s3_bucket_server_side_encryption_configuration.logs
}

moved {
  from = aws_s3_bucket_versioning.cloudtrail
  to   = module.cloudtrail.aws_s3_bucket_versioning.logs
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.cloudtrail
  to   = module.cloudtrail.aws_s3_bucket_lifecycle_configuration.logs
}

moved {
  from = aws_s3_bucket_policy.cloudtrail
  to   = module.cloudtrail.aws_s3_bucket_policy.logs
}

moved {
  from = aws_cloudtrail.audit
  to   = module.cloudtrail.aws_cloudtrail.audit
}
