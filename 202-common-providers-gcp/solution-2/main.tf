//environment   = "PREFIX3"
variable "region" { 
    default = "us-east1"
}
variable "project_id" {
    default = "dazzling-mantra-271319"
}
variable "svc_acct_email" {
  default = "dazzling-mantra-271319@appspot.gserviceaccount.com"
}
variable "user" {
  default ="ed.boykin"
}


terraform {
  backend "gcs" {
    credentials = "../../dazzling-mantra-271319-bcb28c004aed.json"
    bucket  = "my-demo-storage-bucket"
    prefix  = "terraform/state"
  
  }
}

provider "google" {
  credentials = file("../../dazzling-mantra-271319-bcb28c004aed.json")
  region  = "us-east1"
  zone    = "us-east1-a"
  project = "dazzling-mantra-271319"
  
}

resource "google_compute_firewall" "default" {
  name       = "default-firewall"
  network    = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8000", "8080"]
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
  
  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/gcpvmkey.pub")}"
  }
  
  metadata_startup_script = templatefile("vm_startup.tpl", {user = var.user})

}

output "app-URL" {
  description = "Public IP URL."
  value       = "http://${google_compute_instance.compute_instance.network_interface.0.access_config.0.nat_ip}:8000"
}
