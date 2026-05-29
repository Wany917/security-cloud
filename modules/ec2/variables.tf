variable "name_prefix" {
  type        = string
  description = "Prefixe de nommage de l'instance."
}

variable "deploy" {
  type        = bool
  description = "Deploie reellement l'instance. Default false pour eviter tout cout involontaire."
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "Subnet d'accueil de l'instance."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attaches a l'instance."
}

variable "instance_profile_name" {
  type        = string
  description = "Instance profile (role IAM) attache a l'instance."
}

variable "instance_type" {
  type        = string
  description = "Type d'instance."
  default     = "t3.micro"
}

variable "associate_public_ip" {
  type        = bool
  description = "Associe une IP publique a l'instance."
  default     = false
}

variable "user_data" {
  type        = string
  description = "Script user_data optionnel."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
