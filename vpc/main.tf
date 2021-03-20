data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block            = var.cidr_block
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = {
    Name = var.vpc_name
  }
}

# Subnets / NACLS

resource "aws_subnet" "dev" {
  # This line is necessary to ensure that we pick availabiltiy zones that can launch any size ec2 instance
  availability_zone = data.aws_availability_zones.available.names[0]

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 6, 1)


  tags = {
    Name = "dev-subnet"
  }
}

resource "aws_network_acl" "vpc" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = toset([aws_subnet.dev.id] [aws_subnet.public.id])

  ingress {
    protocol   = -1
    rule_no    = 1000
    action     = "allow"
    cidr_block = "0.0.0.0/0"
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

resource "aws_subnet" "public" {
  # This line is necessary to ensure that we pick availabiltiy zones that can launch any size ec2 instance
  availability_zone = data.aws_availability_zones.available.names[0]

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 24, 1)


  tags = {
    Name = "public-subnet"
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
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.vpc_name}-nat-gateway-dev"
  }

  depends_on = [aws_internet_gateway.gw]
}

# VPC Route Table

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.main_route_table_id

    route {
      cidr_block    = "0.0.0.0/0"
      gateway_id    = aws_internet_gateway.gw.id
    }

  tags = {
    Name = "${var.vpc_name}-public"
  }
  depends_on = [aws_internet_gateway.gw]
}

# dev Subnet Route Table

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "dev-route-table"
  }
}

resource "aws_route_table_association" "dev_routes" {
  subnet_id      = aws_subnet.dev.id
  route_table_id = aws_route_table.dev.id

  depends_on = [aws_nat_gateway.gw]
}

resource "aws_route" "dev_nat" {
  route_table_id            = aws_route_table.dev.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.gw.id

  depends_on = [aws_nat_gateway.gw]
}

# Public Subnet Route Table

# dev Subnet Route Table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_routes" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route" "public_igw" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_internet_gateway.gw.id

  depends_on = [aws_internet_gateway.gw]
}
