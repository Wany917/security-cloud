variable "name" {
  type        = string
  description = "Nom complet du secret (ex: prefixe/prod/database)."
}

variable "description" {
  type        = string
  description = "Description du secret."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
