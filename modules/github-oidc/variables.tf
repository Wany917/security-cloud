variable "github_repo" {
  type        = string
  description = "Slug OWNER/REPO autorise a assumer le role via OIDC."
}

variable "role_name" {
  type        = string
  description = "Nom du role assume par GitHub Actions."
  default     = "github-actions-terraform"
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels."
  default     = {}
}
