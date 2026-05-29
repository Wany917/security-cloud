# Tier web : seul point d'entree expose (80/443). Egress libre.
# Description identique a l'existant (immuable apres creation, sinon replace a l'import).
resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-sg-web"
  description = "Zero Trust FYC : trafic web entrant uniquement (80/443)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_ingress_cidrs
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.web_ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg-web" })
}

# Tier BDD : joignable uniquement depuis le SG web (micro-segmentation).
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-sg-db"
  description = "Zero Trust FYC : BDD accessible uniquement depuis le SG web"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL depuis le tier web uniquement"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg-db" })
}
