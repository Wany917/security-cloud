# ──────────────────────────────────────────────────────────────────────────
# Secret applicatif repris en IaC : on gere uniquement le CONTENEUR.
# La valeur (plaintext) reste hors-state, injectee via SOPS/CI, pour ne jamais
# faire transiter le secret en clair par le state Terraform.
# ──────────────────────────────────────────────────────────────────────────

resource "aws_secretsmanager_secret" "this" {
  name        = var.name
  description = var.description
  tags        = var.tags
}
