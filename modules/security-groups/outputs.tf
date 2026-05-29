output "web_sg_id" {
  value       = aws_security_group.web.id
  description = "ID du security group web."
}

output "db_sg_id" {
  value       = aws_security_group.db.id
  description = "ID du security group base de donnees."
}
