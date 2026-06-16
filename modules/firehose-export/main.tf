# ──────────────────────────────────────────────────────────────────────────
# Export canonique CloudWatch Logs -> Kinesis Firehose -> S3.
# Auto-contenu : bucket + cle KMS + roles dedies. Gate cote env
# (var.enable_firehose_export) car Firehose n'est dispo qu'apres upgrade du compte.
#
# Chaine : un subscription filter sur le log group source pousse les events vers
# un delivery stream Firehose, qui les depose chiffres dans un bucket S3.
# ──────────────────────────────────────────────────────────────────────────

data "aws_caller_identity" "current" {}

locals {
  bucket_name = "${var.name_prefix}-cwl-firehose-${data.aws_caller_identity.current.account_id}"
  stream_name = "${var.name_prefix}-cloudtrail-export"
}

# Cle KMS dediee : seul le role Firehose a le droit de chiffrer/dechiffrer.
module "kms" {
  source = "../kms"

  alias          = "${var.name_prefix}/firehose-export"
  description    = "KMS key for CloudWatch->Firehose->S3 export"
  key_admin_arns = var.kms_admin_arns
  key_user_arns  = [aws_iam_role.firehose.arn]

  tags = { Purpose = "firehose-export" }
}

# ── Bucket de destination (durci comme les autres) ──
resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.kms.key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "this" {
  count         = var.access_log_bucket != null ? 1 : 0
  bucket        = aws_s3_bucket.this.id
  target_bucket = var.access_log_bucket
  target_prefix = "${local.bucket_name}/"
}

# ── Log group pour les erreurs de livraison Firehose ──
resource "aws_cloudwatch_log_group" "firehose_errors" {
  name              = "/${var.name_prefix}/firehose-export"
  retention_in_days = 30
}

# ── Role assume par Firehose : ecrire dans S3 + utiliser la cle KMS ──
resource "aws_iam_role" "firehose" {
  name = "${var.name_prefix}-firehose-delivery"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "firehose.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "firehose" {
  name = "${var.name_prefix}-firehose-delivery"
  role = aws_iam_role.firehose.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Delivery"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject",
        ]
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*",
        ]
      },
      {
        Sid      = "KmsForBucket"
        Effect   = "Allow"
        Action   = ["kms:GenerateDataKey", "kms:Decrypt"]
        Resource = module.kms.key_arn
      },
      {
        Sid      = "FirehoseErrorLogs"
        Effect   = "Allow"
        Action   = ["logs:PutLogEvents", "logs:CreateLogStream"]
        Resource = "${aws_cloudwatch_log_group.firehose_errors.arn}:*"
      },
    ]
  })
}

# ── Le delivery stream Firehose -> S3 ──
resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = local.stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose.arn
    bucket_arn          = aws_s3_bucket.this.arn
    prefix              = "cloudtrail/"
    error_output_prefix = "errors/"
    buffering_size      = 5
    buffering_interval  = 300
    compression_format  = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_errors.name
      log_stream_name = "S3Delivery"
    }
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy.firehose]
}

# ── Role assume par CloudWatch Logs : pousser vers Firehose ──
resource "aws_iam_role" "cwl_to_firehose" {
  name = "${var.name_prefix}-cwl-to-firehose"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "logs.${var.region}.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cwl_to_firehose" {
  name = "${var.name_prefix}-cwl-to-firehose"
  role = aws_iam_role.cwl_to_firehose.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["firehose:PutRecord", "firehose:PutRecordBatch"]
      Resource = aws_kinesis_firehose_delivery_stream.this.arn
    }]
  })
}

# ── Le subscription filter : log group source -> Firehose ──
resource "aws_cloudwatch_log_subscription_filter" "this" {
  name            = "${var.name_prefix}-cloudtrail-to-firehose"
  log_group_name  = var.source_log_group_name
  filter_pattern  = var.filter_pattern
  destination_arn = aws_kinesis_firehose_delivery_stream.this.arn
  role_arn        = aws_iam_role.cwl_to_firehose.arn

  depends_on = [aws_iam_role_policy.cwl_to_firehose]
}
