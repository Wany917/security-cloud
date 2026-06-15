variable "bucket_name" {
  type        = string
  description = "Nom du bucket S3 qui stocke le state Terraform."
}

variable "table_name" {
  type        = string
  description = "Nom de la table DynamoDB de verrouillage du state."
}

variable "ci_role_name" {
  type        = string
  description = "Nom du role CI a qui accorder l'acces au state (null = pas de policy)."
  default     = null
}

variable "access_log_bucket" {
  type        = string
  description = "Bucket cible du server access logging du bucket de state (null = desactive)."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
