variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage des ressources reseau (Name tag)."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR du VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR du subnet public."
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR du subnet prive."
  default     = "10.0.2.0/24"
}

variable "az" {
  type        = string
  description = "Availability zone des subnets."
  default     = "eu-west-3a"
}

variable "enable_nat" {
  type        = bool
  description = "Cree une NAT Gateway pour donner une sortie internet au subnet prive. COUTEUX (~0.045 USD/h), desactive par defaut."
  default     = false
}

variable "map_public_ip" {
  type        = bool
  description = "Auto-assignation d'IP publique sur le subnet public."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
