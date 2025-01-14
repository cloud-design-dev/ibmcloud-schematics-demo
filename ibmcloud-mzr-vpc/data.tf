data "ibm_is_ssh_key" "sshkey" {
  name  = var.existing_ssh_key
}

# Pull in the zones in the region
data "ibm_is_zones" "regional" {
  region = var.region
}

data "ibm_resource_group" "group" {
  name = var.existing_resource_group
}

data "ibm_is_images" "images" {
  visibility       = "public"
  status           = "available"
  user_data_format = ["cloud_init"]
}