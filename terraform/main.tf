terraform {
  backend "gcs" {
    bucket      = "iit-lab-state-storage"
    prefix      = "terraform/state"
    credentials = "creds.json"
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_instance" "vm_instance" {
  name         = "iit-lab-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${tls_private_key.ssh_key.public_key_openssh}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for startup script to complete...'",
      "while ! grep -q 'Startup script finished' /var/log/startup-script.log 2>/dev/null; do",
      "  echo 'Executing startup script...'",
      "  sleep 5",
      "done",
      "echo 'Startup script completed successfully!'"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }

  tags = ["web"]

  metadata_startup_script = file("docker.sh")
}

resource "google_compute_firewall" "default" {
  name    = "allow-http-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}
