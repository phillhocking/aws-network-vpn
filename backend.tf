terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "excelsior"

    workspaces {
      name = "aws-network-vpn"
    }
  }
}