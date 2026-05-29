terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

# ──────────────────────────────────────────────────────────────────────────
# "Logs to S3" : archivage natif des VPC flow logs directement dans S3.
# (Kinesis Firehose, le chemin CloudWatch->S3 classique, n'est pas disponible
#  sur le compte student : SubscriptionRequiredException. On utilise donc la
#  livraison native S3 des flow logs, gratuite et supportee partout.)
# ──────────────────────────────────────────────────────────────────────────

# Cle KMS dediee : le service de livraison des logs doit pouvoir chiffrer.
module "kms_archive" {
  source = "../kms"

  alias              = "${var.name_prefix}/logs-archive"
  description        = "KMS key for VPC flow logs S3 archive"
  key_admin_arns     = var.kms_admin_arns
  service_principals = ["delivery.logs.amazonaws.com"]

  tags = {
    Purpose = "logs-archive"
  }
}

resource "aws_s3_bucket" "archive" {
  bucket = "${var.name_prefix}-logs-archive-${var.account_id}"
}

resource "aws_s3_bucket_public_access_block" "archive" {
  bucket                  = aws_s3_bucket.archive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "archive" {
  bucket = aws_s3_bucket.archive.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.kms_archive.key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id
  rule {
    id     = "expire-old-logs"
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

# Policy autorisant le service de livraison des logs a ecrire dans le bucket.
data "aws_iam_policy_document" "archive" {
  statement {
    sid    = "AWSLogDeliveryWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.archive.arn}/AWSLogs/${var.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AWSLogDeliveryAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl", "s3:ListBucket"]
    resources = [aws_s3_bucket.archive.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
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
      aws_s3_bucket.archive.arn,
      "${aws_s3_bucket.archive.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "archive" {
  bucket = aws_s3_bucket.archive.id
  policy = data.aws_iam_policy_document.archive.json
}

# Flow logs livres directement dans S3 (en plus de ceux vers CloudWatch).
resource "aws_flow_log" "to_s3" {
  vpc_id               = var.vpc_id
  traffic_type         = var.traffic_type
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.archive.arn

  tags = merge(var.tags, { Name = "${var.name_prefix}-flow-logs-s3" })

  depends_on = [aws_s3_bucket_policy.archive]
}
