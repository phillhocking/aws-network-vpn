terraform {
  required_providers {
    aws = "~> 3.22.0"
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}