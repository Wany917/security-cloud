# ──────────────────────────────────────────────────────────────────────────
# Backend distant : bucket S3 (state) + table DynamoDB (lock) + acces CI.
# Une fois applique, decommenter le bloc backend "s3" dans providers.tf
# puis lancer : terraform init -migrate-state
# ──────────────────────────────────────────────────────────────────────────

module "tf_backend" {
  source = "../../modules/tf-backend"

  bucket_name       = "${var.project_name}-tfstate-${local.account_id}"
  table_name        = "${var.project_name}-tflock"
  ci_role_name      = module.github_oidc.role_name
  access_log_bucket = module.s3_access_logs.bucket
}

# ── Relocalisation depuis l'env (0 recreation) ──
moved {
  from = aws_s3_bucket.tfstate
  to   = module.tf_backend.aws_s3_bucket.state
}

moved {
  from = aws_s3_bucket_versioning.tfstate
  to   = module.tf_backend.aws_s3_bucket_versioning.state
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.tfstate
  to   = module.tf_backend.aws_s3_bucket_server_side_encryption_configuration.state
}

moved {
  from = aws_s3_bucket_public_access_block.tfstate
  to   = module.tf_backend.aws_s3_bucket_public_access_block.state
}

moved {
  from = aws_dynamodb_table.tflock
  to   = module.tf_backend.aws_dynamodb_table.lock
}

moved {
  from = aws_iam_role_policy.github_state
  to   = module.tf_backend.aws_iam_role_policy.ci_state_access[0]
}

moved {
  from = aws_s3_bucket_logging.tfstate
  to   = module.tf_backend.aws_s3_bucket_logging.state[0]
}
