provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone[1]
  credentials = file(var.credential_location)
}

resource "google_compute_instance" "default" {
  count        = length(var.name_count)
  name         = "server-${count.index + 1}"
  machine_type = var.machine_type["dev"]
  zone         = var.zone[1]

  tags = ["dev"]

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

output "machine_type" { value = "$google_compute_instance.default.*.machine_type" }
output "test" { value = var.zone[1] }