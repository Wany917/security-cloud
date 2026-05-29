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
  name        = "${var.project_name}-analyst-permissions-boundary"
  description = "Permissions boundary pour l'analyst, limite a EC2/S3 read-only."
  policy      = data.aws_iam_policy_document.analyst_permissions_boundary.json
}

import {
  to = aws_iam_user.analyst
  id = var.analyst_user_name
}

resource "aws_iam_user" "analyst" {
  name                 = var.analyst_user_name
  permissions_boundary = aws_iam_policy.analyst_permissions_boundary.arn
}

import {
  to = aws_iam_policy.least_privilege_readonly
  id = "arn:aws:iam::${local.account_id}:policy/${var.least_privilege_policy_name}"
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

import {
  to = aws_iam_user_policy_attachment.analyst_least_privilege
  id = "${var.analyst_user_name}/arn:aws:iam::${local.account_id}:policy/${var.least_privilege_policy_name}"
}

resource "aws_iam_user_policy_attachment" "analyst_least_privilege" {
  user       = aws_iam_user.analyst.name
  policy_arn = aws_iam_policy.least_privilege_readonly.arn
}
