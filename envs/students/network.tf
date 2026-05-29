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

# ──────────────────────────────────────────────────────────────────────────
# Security groups (micro-segmentation web/db)
# ──────────────────────────────────────────────────────────────────────────

module "security_groups" {
  source = "../../modules/security-groups"

  name_prefix = var.legacy_prefix
  vpc_id      = module.network.vpc_id
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
  instance_profile_name = module.iam.instance_profile_name
  associate_public_ip   = true
}
