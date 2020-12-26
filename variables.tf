variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "aws region to use"
}

variable "edge_ip" {
  type        = string
  description = "IP address of edge device for customer gateway"
}
