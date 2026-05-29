# ──────────────────────────────────────────────────────────────────────────
# Lab 3 FYC : secret applicatif repris en IaC (le conteneur ; la valeur reste
# geree hors-state pour ne jamais faire transiter le plaintext par le state).
# Lisible uniquement par le role module.iam (secretsreader).
# ──────────────────────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret" "fyc_db" {
  name        = "${var.legacy_prefix}/prod/database"
  description = "FYC Zero Trust - Demo : credentials BDD (jamais en clair dans le code)"
}
