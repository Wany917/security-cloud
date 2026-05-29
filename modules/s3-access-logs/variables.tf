variable "bucket_name" {
  type        = string
  description = "Nom du bucket central qui recoit les logs d'acces S3."
}

variable "account_id" {
  type        = string
  description = "ID du compte AWS (condition SourceAccount de la policy)."
}

variable "expiration_days" {
  type        = number
  description = "Expiration des logs d'acces (jours)."
  default     = 90
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
