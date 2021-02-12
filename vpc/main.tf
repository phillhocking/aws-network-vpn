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
  # This line is necessary to ensure that we pick availabiltiy zones that can launch any size ec2 instance
  availability_zone = data.aws_availability_zones.available.names[0]

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 6, count.index * 2 + 1)

  tags = {
    Name = "dev-subnet-${count.index}"
  }
}

resource "aws_network_acl" "dev" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.dev[*].id

  ingress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = var.cidr_block
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

# Gateways

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

resource "aws_eip" "nat-gw" {
  vpc = true

  tags = {
    Name = "nat-elastic-ip"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat-gw.id
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

resource "aws_route_table_association" "dev_routes" {
  count = var.subnet_count

  subnet_id      = aws_subnet.dev[count.index].id
  route_table_id = aws_route_table.dev.id
}

resource "aws_route" "dev_nat" {
  route_table_id            = aws_route_table.dev.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id
}