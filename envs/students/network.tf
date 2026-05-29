# ──────────────────────────────────────────────────────────────────────────
# Partie 2 : segregation reseau (VPC Lab 2 FYC repris en IaC + trous combles)
# ──────────────────────────────────────────────────────────────────────────

module "network" {
  source = "../../modules/network"

  name_prefix         = var.legacy_prefix
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  az                  = "${var.region}a"
  enable_nat          = var.enable_nat
  map_public_ip       = true
}

# Import des ressources reseau creees a la main (CLI) lors du Lab 2.
import {
  to = module.network.aws_vpc.this
  id = "vpc-0e854a869b75ffa04"
}

import {
  to = module.network.aws_subnet.public
  id = "subnet-06e3c67d837a9bc59"
}

import {
  to = module.network.aws_subnet.private
  id = "subnet-05eeb6cdb5749f5e5"
}

import {
  to = module.network.aws_internet_gateway.this
  id = "igw-0209a00db4484e80f"
}

# ──────────────────────────────────────────────────────────────────────────
# Security groups (micro-segmentation web/db) repris en IaC
# ──────────────────────────────────────────────────────────────────────────

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix = var.legacy_prefix
  vpc_id      = module.network.vpc_id
}

import {
  to = module.security_groups.aws_security_group.web
  id = "sg-0ef012a57a4334c12"
}

import {
  to = module.security_groups.aws_security_group.db
  id = "sg-0494759d808b0aac1"
}

# ──────────────────────────────────────────────────────────────────────────
# Partie 3 : VPC flow logs vers CloudWatch (chiffres KMS)
# ──────────────────────────────────────────────────────────────────────────

module "kms_logs" {
  source = "../../modules/kms"

  alias       = "${var.project_name}/vpc-logs"
  description = "KMS key for VPC flow logs CloudWatch encryption"

  key_admin_arns     = [local.caller_arn]
  service_principals = ["logs.${var.region}.amazonaws.com"]

  tags = {
    Purpose = "vpc-flow-logs"
  }
}

module "logging" {
  source = "../../modules/logging"

  name_prefix    = var.project_name
  vpc_id         = module.network.vpc_id
  kms_key_arn    = module.kms_logs.key_arn
  retention_days = 30
  traffic_type   = "ALL"
}

# ──────────────────────────────────────────────────────────────────────────
# EC2 durcie IMDSv2 (demo, desactivee par defaut : flip var.deploy_demo_instance)
# ──────────────────────────────────────────────────────────────────────────

module "ec2_web" {
  source = "../../modules/ec2"

  name_prefix           = var.project_name
  deploy                = var.deploy_demo_instance
  subnet_id             = module.network.public_subnet_id
  security_group_ids    = [module.security_groups.web_sg_id]
  instance_profile_name = module.iam_secretsreader.instance_profile_name
  associate_public_ip   = true
}
