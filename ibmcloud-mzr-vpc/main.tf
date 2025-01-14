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

  filtered_images = [
    for image in data.ibm_is_images.images.images :
    image if contains([for os in image.operating_system : os.name], "ubuntu-24-04-amd64")
  ]

}

resource "tailscale_tailnet_key" "lab" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 3600
  description   = "Demo tailscale key for lab"
}

resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  upper   = false
  numeric = false
}

resource "ibm_is_vpc" "vpc" {
  name                        = "${local.prefix}-vpc"
  resource_group              = data.ibm_resource_group.group.id
  address_prefix_management   = var.default_address_prefix
  default_network_acl_name    = "${local.prefix}-default-nacl"
  default_security_group_name = "${local.prefix}-default-sg"
  default_routing_table_name  = "${local.prefix}-default-rt"
  tags                        = local.tags
}

resource "ibm_is_public_gateway" "gateway" {
  name           = "${local.prefix}-${local.vpc_zones[0].zone}-pgw"
  resource_group = data.ibm_resource_group.group.id
  vpc            = ibm_is_vpc.vpc.id
  zone           = local.vpc_zones[0].zone
  tags           = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_subnet" "vpn" {
  name                     = "${local.prefix}-vpn-subnet"
  resource_group           = data.ibm_resource_group.group.id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.vpc_zones[0].zone
  total_ipv4_address_count = "16"
  public_gateway           = ibm_is_public_gateway.gateway.id
  tags                     = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_subnet" "compute" {
  name                     = "${local.prefix}-compute-subnet"
  resource_group           = data.ibm_resource_group.group.id
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.vpc_zones[0].zone
  total_ipv4_address_count = "64"
  public_gateway           = ibm_is_public_gateway.gateway.id
  tags                     = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}


resource "ibm_is_virtual_network_interface" "tailscale" {
  allow_ip_spoofing         = true
  auto_delete               = false
  enable_infrastructure_nat = true
  name                      = "${local.prefix}-ts-vnic"
  subnet                    = ibm_is_subnet.compute.id
  resource_group            = data.ibm_resource_group.group.id
  security_groups           = [ibm_is_vpc.vpc.default_security_group]
  tags                      = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
}

resource "ibm_is_instance" "tailscale" {
  name           = "${local.prefix}-ts-compute"
  vpc            = ibm_is_vpc.vpc.id
  image          = local.filtered_images[0].id
  profile        = var.compute_instance_profile
  resource_group = data.ibm_resource_group.group.id
  metadata_service {
    enabled            = true
    protocol           = "https"
    response_hop_limit = 5
  }

  boot_volume {
    auto_delete_volume = true
  }

  primary_network_attachment {
    name = "${local.prefix}-ts-interface"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.tailscale.id
    }
  }

  zone = local.vpc_zones[0].zone
  keys = [data.ibm_is_ssh_key.sshkey.id]
  tags = concat(local.tags, ["zone:${local.vpc_zones[0].zone}"])
  user_data = templatefile("./ts-router.yaml", {
    tailscale_tailnet_key = tailscale_tailnet_key.lab.key
    tailscale_advertise   = join(",", [ibm_is_subnet.vpn.ipv4_cidr_block], [ibm_is_subnet.compute.ipv4_cidr_block])
  })
}
