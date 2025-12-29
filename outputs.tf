output "east_coast_ip" {
  description = "Public IP address of the east coast proxy"
  value       = digitalocean_droplet.east_coast.ipv4_address
}

output "west_coast_ip" {
  description = "Public IP address of the west coast proxy"
  value       = digitalocean_droplet.west_coast.ipv4_address
}

output "east_coast_librespeed_url" {
  description = "LibreSpeed test URL for east coast proxy"
  value       = "http://${digitalocean_droplet.east_coast.ipv4_address}/librespeed"
}

output "west_coast_librespeed_url" {
  description = "LibreSpeed test URL for west coast proxy"
  value       = "http://${digitalocean_droplet.west_coast.ipv4_address}/librespeed"
}

