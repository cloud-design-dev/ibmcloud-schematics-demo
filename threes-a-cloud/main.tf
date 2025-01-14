locals {
  prefix      = var.project_prefix != "" ? var.project_prefix : "${random_string.prefix.0.result}"
  zones = length(data.ibm_is_zones.regional.zones)
  vpc_zones = {
    for zone in range(local.zones) : zone => {
      zone = "${var.region}-${zone + 1}"
    }
  }

  tags = [
    "provider:ibm",
    "workspace:${terraform.workspace}",
  ]
}

resource "tailscale_tailnet_key" "lab" {
  reusable      = false
  ephemeral     = true
  preauthorized = true
  expiry        = 7776000
  description   = "Demo tailscale key for lab"
}

# IF a resource group was not provided, create a new one
module "resource_group" {
  source                       = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  resource_group_name          = var.existing_resource_group == null ? "${local.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group
}

# Generate a random string if a project prefix was not provided
resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  upper   = false
  numeric = false
}


resource "digitalocean_droplet" "web" {
  image   = "ubuntu-20-04-x64"
  name    = "${local.prefix}-do-instance"
  region  = "nyc2"
  size    = "s-1vcpu-1gb"
  backups = true
  backup_policy {
    plan    = "weekly"
    weekday = "TUE"
    hour    = 8
  }
  ssh_keys = [data.digitalocean_ssh_key.sshkey.id]
  user_data = templatefile("./ts-router.yaml", {
    tailscale_tailnet_key  = tailscale_tailnet_key.lab.key
    tailscale_advertised_subnet = "10.132.0.0/16"
  })
}