variable "existing_resource_group" {
  description = "Name of an existing Resource Group to use for resources. If not set, a new Resource Group will be created."
  type        = string
}

variable "region" {
  description = "IBM Cloud region where resources will be deployed"
  type        = string
}

variable "project_prefix" {
  description = "Prefix to use for resource names"
  type        = string
default = ""
}

variable "existing_ssh_key" {
  description = "Name of an existing SSH key in the region."
  type        = string
}

variable "classic_access" {
  description = "Allow classic access to the VPC."
  type        = bool
  default     = false
}

variable "default_address_prefix" {
  description = "The address prefix to use for the VPC. Default is set to auto."
  type        = string
  default     = "auto"
}

variable "compute_instance_profile" {
  description = "Compute instance profile to use for the Consul servers."
  type        = string
  default     = "bx2-2x8"
}

variable "tailscale_api_key" {
  description = "The Tailscale API key"
  type        = string
  sensitive   = true
}

variable "tailscale_organization" {
  description = "The Tailscale tailnet Organization name. Can be found in the Tailscale admin console > Settings > General."
  type        = string
}