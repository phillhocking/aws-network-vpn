variable "aws_route_table_ids" {
  type        = list(string)
  description = "aws route tables to add vpn routes to"
}

variable "prem_network_address_space" {
  type        = string
  description = "Premise cidr block to give access to the VPN"
}

variable "prem_edge_ip" {
    type        = string
    description = "Premise edge IP"
}
