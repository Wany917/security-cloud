# ──────────────────────────────────────────────────────────────────────────
# Step 4 : IAM hardening - gestion centralisee des identites
# Module unique : user analyst (read-only + boundary) + role machine secretsreader.
# ──────────────────────────────────────────────────────────────────────────

module "iam" {
  source = "../../modules/iam"

  # Role machine (lecture secrets fyc/* uniquement)
  name_prefix         = var.legacy_prefix
  secrets_arn_pattern = "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:${var.legacy_prefix}/*"

  # User analyst (lecture seule + permissions boundary)
  analyst_user_name           = var.analyst_user_name
  least_privilege_policy_name = var.least_privilege_policy_name
  boundary_policy_name        = "${var.project_name}-analyst-permissions-boundary"
}

# ── Relocalisation depuis l'ancien module.iam_secretsreader et l'env (0 recreation) ──
moved {
  from = module.iam_secretsreader.aws_iam_role.secretsreader
  to   = module.iam.aws_iam_role.secretsreader
}

moved {
  from = module.iam_secretsreader.aws_iam_role_policy.read_secrets
  to   = module.iam.aws_iam_role_policy.read_secrets
}

moved {
  from = module.iam_secretsreader.aws_iam_instance_profile.secretsreader
  to   = module.iam.aws_iam_instance_profile.secretsreader
}

moved {
  from = aws_iam_user.analyst
  to   = module.iam.aws_iam_user.analyst
}

moved {
  from = aws_iam_policy.analyst_permissions_boundary
  to   = module.iam.aws_iam_policy.analyst_permissions_boundary
}

moved {
  from = aws_iam_policy.least_privilege_readonly
  to   = module.iam.aws_iam_policy.least_privilege_readonly
}

moved {
  from = aws_iam_user_policy_attachment.analyst_least_privilege
  to   = module.iam.aws_iam_user_policy_attachment.analyst_least_privilege
}
