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

variable "analyst_user_name" {
  type        = string
  description = "Nom du user IAM analyst (lecture seule)."
}

variable "least_privilege_policy_name" {
  type        = string
  description = "Nom de la policy least-privilege readonly de l'analyst."
}

variable "boundary_policy_name" {
  type        = string
  description = "Nom de la permissions boundary de l'analyst."
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
