# ──────────────────────────────────────────────────────────────────────────
# Partie 3 : role machine a permissions limitees (Lab 1 FYC) repris en IaC
# + Lab 3 : secret Secrets Manager repris en IaC
# ──────────────────────────────────────────────────────────────────────────

module "iam_secretsreader" {
  source = "../../modules/iam"

  name_prefix         = var.legacy_prefix
  secrets_arn_pattern = "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:${var.legacy_prefix}/*"
}

import {
  to = module.iam_secretsreader.aws_iam_role.secretsreader
  id = "${var.legacy_prefix}-ec2-secretsreader"
}

import {
  to = module.iam_secretsreader.aws_iam_role_policy.read_secrets
  id = "${var.legacy_prefix}-ec2-secretsreader:${var.legacy_prefix}-read-secrets-only"
}

# Secret applicatif (credentials BDD fictive). On reprend uniquement le conteneur
# du secret sous Terraform ; la valeur (version) reste geree hors-state pour ne
# jamais faire transiter le plaintext par le state Terraform.
resource "aws_secretsmanager_secret" "fyc_db" {
  name        = "${var.legacy_prefix}/prod/database"
  description = "FYC Zero Trust - Demo : credentials BDD (jamais en clair dans le code)"
}

import {
  to = aws_secretsmanager_secret.fyc_db
  id = "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:${var.legacy_prefix}/prod/database-czEFxl"
}
