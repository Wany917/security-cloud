module "kms" {
  source = "../kms"

  alias       = var.kms_alias
  description = "KMS key for CloudTrail logs encryption"

  key_admin_arns     = var.kms_admin_arns
  service_principals = ["cloudtrail.amazonaws.com"]

  tags = {
    Purpose = "cloudtrail"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.kms.key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server access logging du bucket CloudTrail vers le bucket central.
resource "aws_s3_bucket_logging" "logs" {
  count         = var.enable_access_logging ? 1 : 0
  bucket        = aws_s3_bucket.logs.id
  target_bucket = var.access_log_bucket
  target_prefix = "${var.bucket_name}/"
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "archive-old-logs"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.logs.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/AWSLogs/${var.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "DenyUnencryptedTransport"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.bucket.json
}

resource "aws_cloudtrail" "audit" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = module.kms.key_arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    # Data events S3 : trace les acces objets (GetObject/PutObject) sur les
    # buckets sensibles. Repond a la faille du CTF (bucket lu en douce).
    dynamic "data_resource" {
      for_each = length(var.data_event_bucket_arns) > 0 ? [1] : []
      content {
        type   = "AWS::S3::Object"
        values = [for arn in var.data_event_bucket_arns : "${arn}/"]
      }
    }
  }

  depends_on = [
    aws_s3_bucket_policy.logs,
    module.kms,
  ]
}
