data "aws_ami" "debian_12" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  count = var.deploy ? 1 : 0

  ami                         = data.aws_ami.debian_12.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = var.associate_public_ip
  user_data                   = var.user_data

  # Correction de la faille centrale du CTF kungfu : IMDSv2.
  # http_tokens=required interdit l'IMDSv1, http_put_response_hop_limit=1
  # empeche un conteneur/process de rebondir vers les credentials du role.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-web" })
}

# Renommage this -> web (nom representatif), sans recreation.
moved {
  from = aws_instance.this
  to   = aws_instance.web
}
