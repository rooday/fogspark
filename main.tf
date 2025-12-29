provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "main" {
  name = var.ssh_key_name
}

locals {
  east_nginx_files = fileset("${path.module}/nginx-sites-east", "*.conf")
  west_nginx_files = fileset("${path.module}/nginx-sites-west", "*.conf")
  
  east_nginx_configs = {
    for file in local.east_nginx_files :
    file => templatefile("${path.module}/nginx-sites-east/${file}", {
      east_server = var.east_server
      west_server = var.west_server
    })
  }
  
  west_nginx_configs = {
    for file in local.west_nginx_files :
    file => templatefile("${path.module}/nginx-sites-west/${file}", {
      east_server = var.east_server
      west_server = var.west_server
    })
  }
}

resource "digitalocean_droplet" "east_coast" {
  image    = "ubuntu-22-04-x64"
  name     = "${var.project_name}-east"
  region   = var.east_coast_region
  size     = var.droplet_size
  ssh_keys = [data.digitalocean_ssh_key.main.id]
  
  user_data = templatefile("${path.module}/cloud-init-east.yaml", {
    ssh_public_key  = var.ssh_public_key
    nginx_configs   = local.east_nginx_configs
  })
}

resource "digitalocean_droplet" "west_coast" {
  image    = "ubuntu-22-04-x64"
  name     = "${var.project_name}-west"
  region   = var.west_coast_region
  size     = var.droplet_size
  ssh_keys = [data.digitalocean_ssh_key.main.id]
  
  user_data = templatefile("${path.module}/cloud-init-west.yaml", {
    ssh_public_key  = var.ssh_public_key
    nginx_configs   = local.west_nginx_configs
  })
}

