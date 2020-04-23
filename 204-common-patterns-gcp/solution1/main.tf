
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


resource "google_compute_instance_template" "default" {  
  project     = var.project_id
  name_prefix = "default-"

  machine_type = "n1-standard-1"

  region = "us-east1"

  tags = ["allow-service"]

  labels = {}

  network_interface {
    network            = "default"
    subnetwork         = "default"
    access_config {// Ephemeral IP
    }
  }

  can_ip_forward = false

  disk {
    auto_delete  = true
    boot         = true
    source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
    type         = "PERSISTENT"
    disk_type    = "pd-ssd"
    mode         = "READ_WRITE"
  }

  service_account {
    email = var.svc_acct_email 
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  metadata_startup_script = file("vm_startup.txt")

  scheduling {
    preemptible       = false
    automatic_restart = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "default" {
  project            = var.project_id
  name               = "my-default-instance-group"
  description        = "compute VM Instance Group"
  wait_for_instances = false

  base_instance_name = "base-instance"

  version {
    instance_template = google_compute_instance_template.default.self_link
  }

  zone = "us-east1-b"

  target_size = 2

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.mig-health-check.self_link
    initial_delay_sec = 30
  }
}

resource "google_compute_health_check" "mig-health-check" {
  name    = "my-instance-group-hc"
  project = var.project_id

  check_interval_sec  = 30
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 10

  http_health_check {
    port         = 8000
    request_path = "/"
  }
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
