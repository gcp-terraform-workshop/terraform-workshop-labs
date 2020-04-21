provider "google" {
  credentials = file("../../dazzling-mantra-271319-bcb28c004aed.json")
  region  = "us-east1"
  zone    = "us-east1-a"
  project = "dazzling-mantra-271319"
}


// Import these resources that were manually created in GCP

resource "google_compute_network" "vpc_network" {
  name                            = "my-portal-vpc"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false

  timeouts {}

}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "my-portal-vpc-subnet"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc_network.self_link

}
