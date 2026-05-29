variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage des ressources de logging."
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC dont on capture les flow logs."
}

variable "kms_key_arn" {
  type        = string
  description = "ARN de la cle KMS qui chiffre le log group CloudWatch."
}

variable "retention_days" {
  type        = number
  description = "Retention des logs CloudWatch (jours)."
  default     = 30
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
