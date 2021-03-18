variable "vpc_name" {
  type        = string
  description = "the name for the vpc"
}

variable "cidr_block" {
  type        = string
  description = "the cidr block to use for the vpc"
}

variable "prem_network_address_space" {
  type        = string
  description = "Premise network address cidr"
}

variable "prem_edge_ip" {
  type        = string
  description = "Public IP of premise edge for customer gateway" 

}