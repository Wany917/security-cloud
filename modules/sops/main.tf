# Identite applicative dediee a SOPS : seule habilitee a chiffrer/dechiffrer.
resource "aws_iam_user" "sops" {
  name = "${var.name_prefix}-sops-user"
  path = "/sops/"
}

module "kms" {
  source = "../kms"

  alias       = "${var.name_prefix}/sops"
  description = "SOPS secrets encryption for ${var.name_prefix} students environment"

  key_admin_arns = var.kms_admin_arns
  key_user_arns  = [aws_iam_user.sops.arn]

  tags = {
    Purpose = "sops"
  }
}

resource "aws_iam_user_policy" "kms_use" {
  name = "kms-use-sops"
  user = aws_iam_user.sops.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
        ]
        Resource = module.kms.key_arn
      }
    ]
  })
}

resource "aws_iam_access_key" "sops" {
  user = aws_iam_user.sops.name
}
