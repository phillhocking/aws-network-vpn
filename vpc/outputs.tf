output "vpc_id" {
  value       = aws_vpc.main.id
  description = "the id of the vpc"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "cidr prefix of vpc"
}

output "dev_route_table_id" {
  value       = aws_route_table.dev.id
  description = "dev route table for vpc"
}
