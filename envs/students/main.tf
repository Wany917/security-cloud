data "aws_caller_identity" "current" {}

locals {
  account_id     = data.aws_caller_identity.current.account_id
  caller_arn     = data.aws_caller_identity.current.arn
  cloudtrail_kms = module.kms_cloudtrail.key_arn
}
