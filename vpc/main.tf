data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "dev" {
  count = var.subnet_count
  availability_zone = data.aws_availability_zones.available.names[0]

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 6, count.index * 2 + 1)

  tags = {
    Name = "dev-subnet-${count.index}"
  }
}

resource "aws_subnet" "staging" {
  count = var.subnet_count
  availability_zone = data.aws_availability_zones.available.names[1]

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 6, count.index * 2 + 2)

  tags = {
    Name = "staging-subnet-${count.index}"
  }
}

resource "aws_subnet" "prod" {
  count = var.subnet_count
  availability_zone = data.aws_availability_zones.available.names[1]

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 6, count.index * 2 + 3)

  tags = {
    Name = "prod-subnet-${count.index}"
  }
}

resource "aws_network_acl" "dev" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.dev[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "udp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "icmp"
    rule_no    = 600
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "dev-acl"
  }
}

resource "aws_network_acl" "staging" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.staging[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "udp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "icmp"
    rule_no    = 600
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 1100
    action     = "allow"
    cidr_block = var.prem_network_address_space
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "staging-acl"
  }
}

resource "aws_network_acl" "prod" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.prod[*].id

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "udp"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "icmp"
    rule_no    = 600
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = aws_vpc.main.cidr_block
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 1100
    action     = "allow"
    cidr_block = var.prem_network_address_space
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "prod-acl"
  }
}

# Gateways

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

resource "aws_eip" "dev-nat" {
  vpc = true

  tags = {
    Name = "dev-nat-elastic-ip"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.dev-nat.id
  subnet_id     = aws_subnet.dev[0].id

  tags = {
    Name = "${var.vpc_name}-nat-gateway-dev"
  }

  depends_on = [aws_internet_gateway.gw]
}

# Route Tables

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev-route-table"
  }
}

#resource "aws_route" "dev_igw" {
#  route_table_id            = aws_route_table.dev.id
#  destination_cidr_block    = "0.0.0.0/0"
#  gateway_id = aws_internet_gateway.gw.id
#}

resource "aws_route_table" "staging" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "staging-route-table"
  }
}

resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "prod-route-table"
  }
}

resource "aws_route" "dev_nat" {
  route_table_id            = aws_route_table.dev.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
}

resource "aws_route_table_association" "dev_routes" {
  count = var.subnet_count

  subnet_id      = aws_subnet.dev[count.index].id
  route_table_id = aws_route_table.dev.id
}

resource "aws_route_table_association" "staging_routes" {
  count = var.subnet_count

  subnet_id      = aws_subnet.staging[count.index].id
  route_table_id = aws_route_table.staging.id
}

resource "aws_route_table_association" "prod_routes" {
  count = var.subnet_count

  subnet_id      = aws_subnet.prod[count.index].id
  route_table_id = aws_route_table.prod.id
}