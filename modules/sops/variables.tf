variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage (user et alias KMS)."
}

variable "kms_admin_arns" {
  type        = list(string)
  description = "ARNs administrateurs de la cle KMS SOPS."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
