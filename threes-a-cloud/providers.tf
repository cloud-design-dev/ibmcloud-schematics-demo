provider "ibm" {
  region = var.region
}


provider "digitalocean" {
  token = var.do_token
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = var.tailscale_organization
}
