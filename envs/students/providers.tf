terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }

  # PHASE 2 : decommenter apres l'apply de backend.tf, puis
  #   terraform init -migrate-state
  # backend "s3" {
  #   bucket         = "groupe-10-tfstate-107014414516"
  #   key            = "envs/students/terraform.tfstate"
  #   region         = "eu-west-3"
  #   dynamodb_table = "groupe-10-tflock"
  #   encrypt        = true
  #   profile        = "wany"
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "students"
      ManagedBy   = "terraform"
      Owner       = var.project_name
    }
  }
}
