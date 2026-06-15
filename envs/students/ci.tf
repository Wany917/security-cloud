# ──────────────────────────────────────────────────────────────────────────
# Bonus : federation OIDC GitHub Actions (CI/CD sans cle statique)
# ──────────────────────────────────────────────────────────────────────────

module "github_oidc" {
  source = "../../modules/github-oidc"

  github_repo = var.github_repo
}

# ── Relocalisation depuis l'env (0 recreation) ──
moved {
  from = aws_iam_openid_connect_provider.github
  to   = module.github_oidc.aws_iam_openid_connect_provider.github
}

moved {
  from = aws_iam_role.github_actions_terraform
  to   = module.github_oidc.aws_iam_role.this
}

moved {
  from = aws_iam_role_policy_attachment.github_readonly
  to   = module.github_oidc.aws_iam_role_policy_attachment.readonly
}
