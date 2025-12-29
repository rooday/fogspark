variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Name of the SSH key in DigitalOcean"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content for the rooday user"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "fogspark-proxy"
}

variable "droplet_size" {
  description = "DigitalOcean droplet size slug"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "east_coast_region" {
  description = "DigitalOcean region for east coast proxy"
  type        = string
  default     = "nyc1"
}

variable "west_coast_region" {
  description = "DigitalOcean region for west coast proxy"
  type        = string
  default     = "sfo3"
}

variable "east_server" {
  description = "Backend server address for east coast (e.g., http://east.example.com)"
  type        = string
}

variable "west_server" {
  description = "Backend server address for west coast (e.g., http://west.example.com)"
  type        = string
}

