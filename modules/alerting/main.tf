# ──────────────────────────────────────────────────────────────────────────
# Alerting : CloudTrail -> CloudWatch Logs -> metric filters -> alarmes -> SNS.
# Repond au volet "alerting" du Step 3 (Logs & alerting).
# ──────────────────────────────────────────────────────────────────────────

# Log group qui recoit les events CloudTrail (support des metric filters).
resource "aws_cloudwatch_log_group" "trail" {
  name              = "/${var.name_prefix}/cloudtrail"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, { Name = "${var.name_prefix}-cloudtrail-logs" })
}

# Role assume par CloudTrail pour ecrire dans le log group.
data "aws_iam_policy_document" "trail_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "trail_cw" {
  name               = "${var.name_prefix}-cloudtrail-to-cw"
  assume_role_policy = data.aws_iam_policy_document.trail_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "trail_cw" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.trail.arn}:*"]
  }
}

resource "aws_iam_role_policy" "trail_cw" {
  name   = "${var.name_prefix}-cloudtrail-to-cw"
  role   = aws_iam_role.trail_cw.id
  policy = data.aws_iam_policy_document.trail_cw.json
}

# Topic SNS chiffre des alertes de securite.
resource "aws_sns_topic" "alerts" {
  name              = "${var.name_prefix}-security-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = var.tags
}

data "aws_iam_policy_document" "topic" {
  statement {
    sid    = "AllowCloudWatchAlarmsPublish"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_sns_topic_policy" "alerts" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.topic.json
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ── Metric filters + alarmes sur les evenements sensibles ──
locals {
  filters = {
    root_usage = {
      pattern     = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
      description = "Utilisation du compte root detectee"
    }
    unauthorized_api = {
      pattern     = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
      description = "Appels API non autorises (AccessDenied / UnauthorizedOperation)"
    }
    iam_changes = {
      pattern     = "{ ($.eventName = PutUserPolicy) || ($.eventName = PutRolePolicy) || ($.eventName = AttachUserPolicy) || ($.eventName = AttachRolePolicy) || ($.eventName = CreateUser) || ($.eventName = CreatePolicy) || ($.eventName = CreateAccessKey) }"
      description = "Modification de la configuration IAM"
    }
    cloudtrail_tampering = {
      pattern     = "{ ($.eventName = StopLogging) || ($.eventName = DeleteTrail) || ($.eventName = UpdateTrail) }"
      description = "Alteration de la journalisation CloudTrail"
    }
    tfstate_read = {
      pattern     = "{ ($.eventName = GetObject) && ($.requestParameters.bucketName = \"${var.tfstate_bucket_name}\") }"
      description = "Lecture du bucket de state Terraform (contient des secrets)"
    }
  }
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each       = local.filters
  name           = "${var.name_prefix}-${each.key}"
  log_group_name = aws_cloudwatch_log_group.trail.name
  pattern        = each.value.pattern

  metric_transformation {
    name          = "${var.name_prefix}-${each.key}"
    namespace     = "${var.name_prefix}/Security"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each            = local.filters
  alarm_name          = "${var.name_prefix}-${each.key}"
  alarm_description   = each.value.description
  namespace           = "${var.name_prefix}/Security"
  metric_name         = "${var.name_prefix}-${each.key}"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  tags = var.tags
}
