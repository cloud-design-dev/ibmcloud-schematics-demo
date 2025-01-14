variable "region" {
  description = "The region in which the IBM Cloud resources will be deployed"
    type        = string
  default     = "us-east"
}

variable "existing_do_ssh_key" {
  description = "The name of the existing DigitalOcean SSH key"
    type = string
}

variable "existing_ibm_ssh_key" {
  description = "The name of the existing IBM Cloud SSH key"
    type = string
    default = "rst-us-east"
}

variable "project_prefix" {
    description = "The prefix to use for the project"
        type = string
        default = ""
}

variable "do_token" {
  description = "Digital ocean token"
  type = string
  sensitive = true
}

variable "tailscale_organization" {
  description = "Tailscale organization for authentication"
  type = string
  sensitive = true
}

variable "tailscale_api_key" {
  description = "Tailscale API key for authentication"
  type = string
  sensitive = true
}
