variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage."
}

variable "account_id" {
  type        = string
  description = "ID du compte AWS."
}

variable "kms_key_arn" {
  type        = string
  description = "Cle KMS pour chiffrer le log group CloudTrail et le topic SNS. Doit autoriser les services logs, cloudwatch et sns."
}

variable "tfstate_bucket_name" {
  type        = string
  description = "Nom du bucket de state, surveille en lecture (data event GetObject)."
}

variable "log_retention_days" {
  type        = number
  description = "Retention du log group CloudTrail (jours)."
  default     = 90
}

variable "alert_email" {
  type        = string
  description = "Adresse e-mail abonnee aux alertes (vide = pas d'abonnement). L'abonnement doit etre confirme par mail."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
