# ──────────────────────────────────────────────────────────────────────────
# S3 server access logging : qui fait quelle requete sur les buckets.
# Bucket central qui recoit les logs d'acces des autres buckets.
# ──────────────────────────────────────────────────────────────────────────

module "s3_access_logs" {
  source = "../../modules/s3-access-logs"

  bucket_name = "${var.project_name}-s3-access-logs-${local.account_id}"
  account_id  = local.account_id
}

# Logging d'acces du bucket de state (le plus sensible : il contient des secrets).
resource "aws_s3_bucket_logging" "tfstate" {
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = module.s3_access_logs.bucket
  target_prefix = "${aws_s3_bucket.tfstate.id}/"
}

locals {
  # Buckets sensibles surveilles par les data events CloudTrail (acces objets).
  # On exclut le bucket CloudTrail lui-meme pour eviter une boucle de logging.
  data_event_bucket_arns = [
    aws_s3_bucket.tfstate.arn,
    "arn:aws:s3:::${var.project_name}-logs-archive-${local.account_id}",
  ]
}
