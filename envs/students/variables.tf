variable "region" {
  type        = string
  description = "Region AWS de deploiement."
  default     = "eu-west-3"
}

variable "aws_profile" {
  type        = string
  description = "Nom du profil AWS SSO local."
  default     = "wany"
}

variable "project_name" {
  type        = string
  description = "Prefixe utilise pour nommer les nouvelles ressources."
  default     = "groupe-10"
}

variable "legacy_prefix" {
  type        = string
  description = "Prefixe des ressources existantes a conserver (CloudTrail, analyst, etc.)."
  default     = "fyc"
}

variable "cloudtrail_bucket_name" {
  type        = string
  description = "Nom du bucket S3 CloudTrail existant a importer."
  default     = "fyc-cloudtrail-logs-107014414516"
}

variable "cloudtrail_trail_name" {
  type        = string
  description = "Nom du trail CloudTrail existant a importer."
  default     = "fyc-audit-trail"
}

variable "analyst_user_name" {
  type        = string
  description = "Nom du user IAM analyst existant a importer."
  default     = "fyc-analyst"
}

variable "least_privilege_policy_name" {
  type        = string
  description = "Nom de la policy least-privilege existante a importer."
  default     = "fyc-least-privilege-readonly"
}

variable "enable_nat" {
  type        = bool
  description = "Active une NAT Gateway pour le subnet prive. COUTEUX, off par defaut."
  default     = false
}

variable "deploy_demo_instance" {
  type        = bool
  description = "Deploie l'EC2 de demo durcie IMDSv2 (free-tier t3.micro). Off par defaut."
  default     = false
}

variable "github_repo" {
  type        = string
  description = "Slug OWNER/REPO autorise a assumer le role CI via OIDC."
  default     = "Wany917/security-cloud"
}

variable "alert_email" {
  type        = string
  description = "E-mail abonne aux alertes de securite SNS (vide = topic seul, sans abonnement)."
  default     = ""
}
