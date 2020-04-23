provider "google" {
  version = "3.5.0"

  credentials = file("terraform.json")

  project = "terraform-containers"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

data "google_container_registry_repository" "terraform-containers" {
}

resource "google_compute_firewall" "default" {
  name       = "default-firewall"
  network    = "terraform-network"

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_ranges = ["0.0.0.0/0"]
}
