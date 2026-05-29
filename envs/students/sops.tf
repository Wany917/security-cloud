# ──────────────────────────────────────────────────────────────────────────
# Step 1 : gestion des secrets - user SOPS + cle KMS dediee
# ──────────────────────────────────────────────────────────────────────────

module "sops" {
  source = "../../modules/sops"

  name_prefix    = var.project_name
  kms_admin_arns = [local.caller_arn]
}

# ── Relocalisation depuis l'env (0 recreation) ──
moved {
  from = aws_iam_user.sops
  to   = module.sops.aws_iam_user.sops
}

moved {
  from = aws_iam_user_policy.sops_kms_use
  to   = module.sops.aws_iam_user_policy.kms_use
}

moved {
  from = aws_iam_access_key.sops
  to   = module.sops.aws_iam_access_key.sops
}

moved {
  from = module.kms_sops
  to   = module.sops.module.kms
}
