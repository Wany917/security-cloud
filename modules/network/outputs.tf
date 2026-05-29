output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID du VPC."
}

output "vpc_arn" {
  value       = aws_vpc.this.arn
  description = "ARN du VPC."
}

output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block
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
  value       = aws_internet_gateway.this.id
  description = "ID de l'Internet Gateway."
}
