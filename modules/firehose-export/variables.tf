variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage."
}

variable "source_log_group_name" {
  type        = string
  description = "Nom du log group CloudWatch a exporter vers S3 (ex: le log group CloudTrail)."
}

variable "region" {
  type        = string
  description = "Region AWS (pour le principal du service CloudWatch Logs)."
}

variable "kms_admin_arns" {
  type        = list(string)
  description = "ARNs administrateurs de la cle KMS dediee."
  default     = []
}

variable "filter_pattern" {
  type        = string
  description = "Filtre des events a exporter (vide = tout)."
  default     = ""
}

variable "access_log_bucket" {
  type        = string
  description = "Bucket de logs d'acces S3 (null = pas de journalisation d'acces)."
  default     = null
}

variable "alarm_sns_topic_arn" {
  type        = string
  description = "Topic SNS a alerter si la livraison Firehose vers S3 deraille (null = pas d'alarme)."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
