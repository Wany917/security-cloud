terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

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
