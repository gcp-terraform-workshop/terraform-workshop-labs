
terraform {
  backend "gcs" {
    bucket  = "booth-demo-storage-bucket"
    prefix  = "terraform/state"
  
  }
}

provider "google" {
  region  = "us-east1"
  zone    = "us-east1-a"
  project = var.project_id
  
}

resource "google_compute_firewall" "default" {
  name       = "default-firewall"
  network    = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "compute_instance" {
  name         = "gcp-vm"
  machine_type = "n1-standard-1"
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email = var.svc_acct_email 
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}