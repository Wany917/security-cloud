output "username" {
  value = aws_iam_user.groupe10_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.groupe10_access_key.id
}

output "access_key_secret" {
  value     = aws_iam_access_key.groupe10_access_key.secret
  sensitive = true
}
