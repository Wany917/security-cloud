variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage."
}

variable "vpc_id" {
  type        = string
  description = "VPC dont les flow logs sont archives directement dans S3."
}

variable "account_id" {
  type        = string
  description = "ID du compte AWS."
}

variable "kms_admin_arns" {
  type        = list(string)
  description = "ARNs administrateurs de la cle KMS de l'archive."
  default     = []
}

variable "traffic_type" {
  type        = string
  description = "Type de trafic capture (ACCEPT, REJECT, ALL)."
  default     = "ALL"
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

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
