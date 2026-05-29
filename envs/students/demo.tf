# ──────────────────────────────────────────────────────────────────────────
# DEMO "rejouer l'attaque" (gated par deploy_demo_instance, off par defaut).
# Deploie l'app vulnerable du CTF sur l'EC2 durcie + un SG qui n'ouvre qu'a
# TON IP (l'app a une RCE, jamais exposee a internet).
# ──────────────────────────────────────────────────────────────────────────

data "http" "my_ip" {
  count = var.deploy_demo_instance ? 1 : 0
  url   = "http://ipv4.icanhazip.com/"
}

locals {
  operator_cidr = var.deploy_demo_instance ? "${chomp(data.http.my_ip[0].response_body)}/32" : "0.0.0.0/0"
}

resource "aws_security_group" "demo_web" {
  count       = var.deploy_demo_instance ? 1 : 0
  name        = "${var.project_name}-demo-web"
  description = "DEMO : app vulnerable accessible uniquement depuis l'IP de l'operateur"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP depuis IP operateur uniquement"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.operator_cidr]
  }

  ingress {
    description = "SSH depuis IP operateur uniquement"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.operator_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-demo-web" }
}
