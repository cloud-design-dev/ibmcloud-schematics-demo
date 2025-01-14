data "ibm_is_ssh_key" "sshkey" {
  name  = var.existing_ibm_ssh_key
}

# Pull in the zones in the region
data "ibm_is_zones" "regional" {
  region = var.region
}

data "digitalocean_ssh_key" "sshkey" {
  name = var.existing_do_ssh_key
}