# ──────────────────────────────────────────────────────────────────────────
# Federation OIDC GitHub Actions : les workflows assument un role AWS sans
# cle statique stockee. Le role est scope au seul depot autorise.
# ──────────────────────────────────────────────────────────────────────────

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

data "aws_iam_policy_document" "assume" {
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

resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = "Role assume par GitHub Actions pour terraform plan (read-only)."
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Read-only suffit pour `terraform plan` (refresh). L'apply reste manuel/local.
resource "aws_iam_role_policy_attachment" "readonly" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
