output "instance_id" {
  value       = var.deploy ? aws_instance.web[0].id : null
  description = "ID de l'instance (null si non deployee)."
}

output "private_ip" {
  value       = var.deploy ? aws_instance.web[0].private_ip : null
  description = "IP privee de l'instance."
}

output "public_ip" {
  value       = var.deploy ? aws_instance.web[0].public_ip : null
  description = "IP publique de l'instance (si associee)."
}
