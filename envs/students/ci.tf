# ──────────────────────────────────────────────────────────────────────────
# Partie 3 : CI/CD reelle - federation OIDC GitHub Actions (pas de cle statique)
# ──────────────────────────────────────────────────────────────────────────

# Provider OIDC GitHub : permet aux workflows d'assumer un role AWS sans secret.
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]

  tags = {
    Purpose = "github-actions-oidc"
  }
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Scope au repo uniquement : seul ce depot peut assumer le role.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions_terraform" {
  name               = "github-actions-terraform"
  description        = "Role assume par GitHub Actions pour terraform plan (read-only)."
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

# Read-only suffit pour `terraform plan` (refresh). L'apply reste manuel/local.
resource "aws_iam_role_policy_attachment" "github_readonly" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
