resource "aws_iam_role" "groupe10_role" {
  name = "tf-${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "groupe10_role_policy" {
  name = "tf-${var.instance_name}-policy"
  role = aws_iam_role.groupe10_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:List*",
          "s3:Get*",
          "s3:Describe*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}