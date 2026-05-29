output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID du VPC."
}

output "vpc_arn" {
  value       = aws_vpc.main.arn
  description = "ARN du VPC."
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "CIDR du VPC."
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "ID du subnet public."
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "ID du subnet prive."
}

output "igw_id" {
  value       = aws_internet_gateway.main.id
  description = "ID de l'Internet Gateway."
}
