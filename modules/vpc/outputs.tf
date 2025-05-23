output "vpc_id" {
  value = aws_vpc.vpc.id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value = values(aws_subnet.public_subnet)[*].id
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value = values(aws_subnet.private_subnet)[*].id
  description = "IDs of the private subnets"
}

output "public_route_table_id" {
  value = aws_route_table.public_route_table.id
  description = "ID of the public route table"
}

output "private_route_table_ids" {
  value = {
    for k, v in aws_route_table.private_route_table : k => v.id
  }
  description = "IDs of the private route tables"
}

output "nat_gateway_ids" {
  value = values(aws_nat_gateway.nat_gateway)[*].id
  description = "IDs of the NAT gateways"
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
  description = "ID of the Internet Gateway"
} 