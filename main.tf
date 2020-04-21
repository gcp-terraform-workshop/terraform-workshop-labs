provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone[1]
}

resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "n1-standard-1"
  zone         = var.zone[1]
  
boot_disk {
  initialize_params {
    image = "ubuntu-os-cloud/ubuntu-minimal-1910"
  }
}

scratch_disk {
interface = "SCSI"
  }

 network_interface {
    network = "default"
  }

}