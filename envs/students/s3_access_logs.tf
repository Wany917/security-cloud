# ──────────────────────────────────────────────────────────────────────────
# S3 server access logging : bucket central qui recoit les logs d'acces des
# autres buckets (cloudtrail, archive, state).
# ──────────────────────────────────────────────────────────────────────────

module "s3_access_logs" {
  source = "../../modules/s3-access-logs"

  bucket_name = "${var.project_name}-s3-access-logs-${local.account_id}"
  account_id  = local.account_id
}

locals {
  # Buckets sensibles surveilles par les data events CloudTrail (acces objets).
  # On exclut le bucket CloudTrail lui-meme pour eviter une boucle de logging.
  data_event_bucket_arns = [
    module.tf_backend.bucket_arn,
    "arn:aws:s3:::${var.project_name}-logs-archive-${local.account_id}",
  ]
}
