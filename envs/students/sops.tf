resource "aws_iam_user" "sops" {
  name = "${var.project_name}-sops-user"
  path = "/sops/"
}

resource "aws_iam_user_policy" "sops_kms_use" {
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
        Resource = module.kms_sops.key_arn
      }
    ]
  })
}

resource "aws_iam_access_key" "sops" {
  user = aws_iam_user.sops.name
}

module "kms_sops" {
  source = "../../modules/kms"

  alias       = "${var.project_name}/sops"
  description = "SOPS secrets encryption for ${var.project_name} students environment"

  key_admin_arns = [local.caller_arn]
  key_user_arns  = [aws_iam_user.sops.arn]

  tags = {
    Purpose = "sops"
  }
}
