output "role_name" {
  value       = aws_iam_role.secretsreader.name
  description = "Nom du role secretsreader."
}

output "role_arn" {
  value       = aws_iam_role.secretsreader.arn
  description = "ARN du role secretsreader."
}

output "instance_profile_name" {
  value       = var.create_instance_profile ? aws_iam_instance_profile.secretsreader[0].name : null
  description = "Nom de l'instance profile (null si non cree)."
}
