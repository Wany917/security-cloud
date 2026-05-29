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

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
