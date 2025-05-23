resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  for_each = {
    for idx, az in var.availability_zones : az => idx
  }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr[each.value]
  availability_zone = each.key
  tags = {
    Name = "public_subnet_${each.key}"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each = {
    for idx, az in var.availability_zones : az => idx
  }
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr[each.value]
  availability_zone = each.key
  tags = {
    Name = "private_subnet_${each.key}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public_subnet
  domain   = "vpc"
  tags = {
    Name = "nat_eip_${each.key}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = aws_subnet.public_subnet
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id
  tags = {
    Name = "nat_gateway_${each.key}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  for_each = aws_subnet.private_subnet
  vpc_id = aws_vpc.vpc.id
  route {   
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }
  tags = {
    Name = "private_route_table_${each.key}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

