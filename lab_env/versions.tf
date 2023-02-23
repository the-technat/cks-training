terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "alleaffengaffen"

    workspaces {
      name = "cks"
    }

  }
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    hetznerdns = {
      source = "timohirt/hetznerdns"
    }
  }
}
