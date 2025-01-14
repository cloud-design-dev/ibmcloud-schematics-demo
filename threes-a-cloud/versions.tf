terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.75.0-beta0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.16.2"
    }

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.47.0"
    }
  }
}
