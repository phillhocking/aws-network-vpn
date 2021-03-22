# Required Variables - These variables must be provided with values

variable "vpc_id" {
  type        = string
  description = "ID of the VPC created by VPC module"
}

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
