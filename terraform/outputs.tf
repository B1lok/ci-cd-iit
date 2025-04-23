output "external_ip" {
  description = "External IP of the GCP VM"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "private_key" {
  description = "Private SSH key to access the instance"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "public_key" {
  description = "Public SSH key"
  value       = tls_private_key.ssh_key.public_key_openssh
}
