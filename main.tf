module "vpc" {
  source                     = "./vpc"
  vpc_name                   = "aws-vpn-vpc"
  cidr_block                 = "10.21.0.0/16"
  prem_network_address_space = "10.20.0.0/16"
  prem_edge_ip               = var.edge_ip
  subnet_count               = 1
}

module "vpn" {
  source                      = "./vpn"
  
  aws_route_table_ids = module.vpc.route_table_ids
  
  vpc_id                     = module.vpc.vpc_id
  prem_network_address_space = "10.20.0.0/16"
  prem_edge_ip               = var.edge_ip

  depends_on                 = [
    module.vpc,
  ]  
}
