variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage des security groups."
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC qui porte les security groups."
}

variable "web_ingress_cidrs" {
  type        = list(string)
  description = "CIDR autorises a joindre le tier web (80/443)."
  default     = ["0.0.0.0/0"]
}

variable "db_port" {
  type        = number
  description = "Port de la base de donnees (PostgreSQL par defaut)."
  default     = 5432
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
