# Role machine (Lab 1 FYC) : identite d'une EC2 limitee a la lecture des secrets fyc/*.
data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "secretsreader" {
  name               = "${var.name_prefix}-ec2-secretsreader"
  description        = var.role_description
  assume_role_policy = data.aws_iam_policy_document.assume.json

  tags = var.tags
}

data "aws_iam_policy_document" "read_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [var.secrets_arn_pattern]
  }
}

resource "aws_iam_role_policy" "read_secrets" {
  name   = "${var.name_prefix}-read-secrets-only"
  role   = aws_iam_role.secretsreader.id
  policy = data.aws_iam_policy_document.read_secrets.json
}

# Instance profile : manquait dans la conf CLI, requis pour attacher le role a l'EC2.
resource "aws_iam_instance_profile" "secretsreader" {
  count = var.create_instance_profile ? 1 : 0
  name  = "${var.name_prefix}-ec2-secretsreader"
  role  = aws_iam_role.secretsreader.name

  tags = var.tags
}

# ──────────────────────────────────────────────────────────────────────────
# User analyst (Lab 1 FYC) : lecture seule, borne par une permissions boundary.
# ──────────────────────────────────────────────────────────────────────────
data "aws_iam_policy_document" "analyst_permissions_boundary" {
  statement {
    sid    = "AllowReadOnlyOnEC2andS3"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:List*",
      "s3:GetObject",
      "s3:ListBucket",
      "sts:GetCallerIdentity",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DenyAnyIAMWrite"
    effect    = "Deny"
    actions   = ["iam:*"]
    resources = ["*"]
  }

  statement {
    sid    = "DenySecretsAndKMSWrite"
    effect = "Deny"
    actions = [
      "kms:Create*",
      "kms:Put*",
      "kms:Schedule*",
      "kms:Disable*",
      "kms:Delete*",
      "kms:Cancel*",
      "secretsmanager:Create*",
      "secretsmanager:Put*",
      "secretsmanager:Delete*",
      "secretsmanager:Update*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "analyst_permissions_boundary" {
  name        = var.boundary_policy_name
  description = "Permissions boundary pour l'analyst, limite a EC2/S3 read-only."
  policy      = data.aws_iam_policy_document.analyst_permissions_boundary.json
}

resource "aws_iam_user" "analyst" {
  name                 = var.analyst_user_name
  permissions_boundary = aws_iam_policy.analyst_permissions_boundary.arn
}

resource "aws_iam_policy" "least_privilege_readonly" {
  name        = var.least_privilege_policy_name
  description = "Policy moindre privilege pour demo Zero Trust FYC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LectureSeuleEC2"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:List*",
        ]
        Resource = "*"
      },
      {
        Sid    = "LectureSeuleS3"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "analyst_least_privilege" {
  user       = aws_iam_user.analyst.name
  policy_arn = aws_iam_policy.least_privilege_readonly.arn
}
