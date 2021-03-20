resource "aws_vpn_gateway" "main" {
  vpc_id = module.vpc.vpc_id

  tags = {
    Name = "vpn-gateway"
  }
}

resource "aws_vpn_gateway_route_propagation" "main" {
  count = length(var.aws_route_table_ids)

  route_table_id = var.aws_route_table_ids[count.index]
  vpn_gateway_id = aws_vpn_gateway.main.id

  depends_on = [ 
    aws_vpn_gateway.main,
  ]
}


resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = var.prem_edge_ip
  type       = "ipsec.1"

  tags = {
    Name = "main-vpn-customer-gateway"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "main-vpn-connection"
  }

  depends_on = [ 
    aws_vpn_gateway.main,
    aws_customer_gateway.main,
  ]
}

resource "aws_vpn_connection_route" "main" {
  vpn_connection_id      = aws_vpn_connection.main.id
  destination_cidr_block = var.prem_network_address_space

  depends_on = [ 
    aws_vpn_connection.main,
  ]
}
