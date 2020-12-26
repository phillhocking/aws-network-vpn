terraform {
  required_providers {
    aws = "~> 3.22.0"
  }
}

provider "aws" {
  region = var.aws_region
}