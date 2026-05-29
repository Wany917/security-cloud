data "aws_caller_identity" "current" {}

resource "aws_iam_user" "groupe10_user" {
  name          = "tf-${var.username}-user"
  force_destroy = true
}

resource "aws_iam_access_key" "groupe10_access_key" {
  user = aws_iam_user.groupe10_user.name
}

data "aws_iam_policy" "full_read_only_policy" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "attach_full_read_only" {
  name       = "tf-attach-readonly-${var.username}"
  users      = [aws_iam_user.groupe10_user.name]
  policy_arn = data.aws_iam_policy.full_read_only_policy.arn
}

resource "aws_iam_user_policy" "groupe10_policy" {
  name = "tf-${var.policy_name}-policy"
  user = aws_iam_user.groupe10_user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:AttachUserPolicy",
          "iam:CreateUser"
        ],
        "Resource" : [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/fake-admin-groupe10*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/tf-fake-admin-groupe10-policy"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "fake_admin_policy" {
  name = "tf-fake-admin-groupe10-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances" # TODO : A CHANGER
        ],
        "Resource" : "*"
      }
    ]
  })
}
