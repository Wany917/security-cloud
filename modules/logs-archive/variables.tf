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

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
