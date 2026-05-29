variable "alias" {
  type        = string
  description = "Nom de l'alias KMS sans le prefixe 'alias/'."
  validation {
    condition     = can(regex("^[a-zA-Z0-9/_-]+$", var.alias))
    error_message = "L'alias doit contenir uniquement des caracteres alphanumeriques, /, _ ou -."
  }
}

variable "description" {
  type        = string
  description = "Description fonctionnelle de la cle (ex: 'SOPS secrets for students env')."
}

variable "key_admin_arns" {
  type        = list(string)
  description = "ARNs IAM autorises a administrer la cle (rotation, suppression, policy)."
  default     = []
}

variable "key_user_arns" {
  type        = list(string)
  description = "ARNs IAM autorises a utiliser la cle (encrypt/decrypt/generate data key)."
  default     = []
}

variable "service_principals" {
  type        = list(string)
  description = "AWS service principals autorises a generer des data keys (ex: cloudtrail.amazonaws.com)."
  default     = []
}

variable "deletion_window_in_days" {
  type        = number
  description = "Fenetre de suppression KMS (7-30 jours)."
  default     = 30
  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "Doit etre entre 7 et 30."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
