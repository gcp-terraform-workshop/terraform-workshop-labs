output "public_ip" {
  value = google_compute_instance.compute_instance.network_interface.0.access_config.0.nat_ip
}

output "network_address" {
  value = "${google_compute_instance.compute_instance.network_interface.0.access_config.0.nat_ip}:8080"
}