variable "kms_alias" {
  type        = string
  description = "Alias de la cle KMS de chiffrement des logs (sans prefixe 'alias/')."
}

variable "bucket_name" {
  type        = string
  description = "Nom du bucket S3 destination des logs CloudTrail."
}

variable "trail_name" {
  type        = string
  description = "Nom du trail CloudTrail."
}

variable "account_id" {
  type        = string
  description = "ID du compte AWS."
}

variable "kms_admin_arns" {
  type        = list(string)
  description = "ARNs administrateurs de la cle KMS."
  default     = []
}

variable "enable_access_logging" {
  type        = bool
  description = "Active le server access logging du bucket vers access_log_bucket."
  default     = false
}

variable "access_log_bucket" {
  type        = string
  description = "Bucket cible des logs d'acces S3."
  default     = null
}

variable "data_event_bucket_arns" {
  type        = list(string)
  description = "ARNs des buckets dont on capture les data events S3 (acces objets) dans CloudTrail."
  default     = []
}

variable "cloudwatch_logs_group_arn" {
  type        = string
  description = "ARN du log group CloudWatch (sans :*) vers lequel livrer les events. null = pas de livraison CloudWatch."
  default     = null
}

variable "cloudwatch_logs_role_arn" {
  type        = string
  description = "ARN du role assume par CloudTrail pour ecrire dans CloudWatch Logs."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
