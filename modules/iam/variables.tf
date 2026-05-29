variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage du role et de sa policy."
}

variable "secrets_arn_pattern" {
  type        = string
  description = "Pattern ARN des secrets que le role peut lire (ex: arn:...:secret:fyc/*)."
}

variable "role_description" {
  type        = string
  description = "Description du role IAM."
  default     = "Role IAM Zero Trust FYC : EC2 lit les secrets, rien d'autre"
}

variable "create_instance_profile" {
  type        = bool
  description = "Cree un instance profile pour attacher le role a une EC2."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
