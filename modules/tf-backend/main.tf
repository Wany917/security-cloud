# ──────────────────────────────────────────────────────────────────────────
# Backend distant Terraform : bucket S3 (state) + table DynamoDB (lock).
# Le state contient des secrets : bucket prive, chiffre, versionne, logge.
# ──────────────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "state" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "state" {
  count         = var.access_log_bucket != null ? 1 : 0
  bucket        = aws_s3_bucket.state.id
  target_bucket = var.access_log_bucket
  target_prefix = "${aws_s3_bucket.state.id}/"
}

resource "aws_dynamodb_table" "lock" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Acces au state pour le role CI (read state + lock CRUD, suffisant pour plan).
data "aws_iam_policy_document" "ci_state_access" {
  statement {
    sid       = "ListStateBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]
  }
  statement {
    sid       = "ReadState"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.state.arn}/*"]
  }
  statement {
    sid    = "LockTable"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [aws_dynamodb_table.lock.arn]
  }
}

resource "aws_iam_role_policy" "ci_state_access" {
  count  = var.ci_role_name != null ? 1 : 0
  name   = "tfstate-access"
  role   = var.ci_role_name
  policy = data.aws_iam_policy_document.ci_state_access.json
}
