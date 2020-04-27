provider "google" {
  region  = var.region
  zone    = var.zone
  project = var.project

}

data "google_compute_network" "default" {
  name = "default"
}



resource "google_compute_router" "router" {
  name    = "my-router"
  region  = var.region
  network = data.google_compute_network.default.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_global_address" "public" {
  name = "public"
}

resource "google_compute_global_forwarding_rule" "paas-monitor" {
  name       = "paas-monitor"
  ip_address = google_compute_global_address.public.address
  port_range = "80"
  target     = google_compute_target_http_proxy.public.self_link
}

resource "google_compute_target_http_proxy" "public" {
  name    = "paas-monitor"
  url_map = google_compute_url_map.paas-monitor.self_link
}

resource "google_compute_url_map" "paas-monitor" {
  name            = "paas-monitor"
  default_service = google_compute_backend_service.service.self_link
}

resource "google_compute_firewall" "paas-monitor" {
  ## firewall rules enabling the load balancer health checks
  name    = "paas-monitor-firewall"
  network = "default"

  description = "allow Google health checks and network load balancers access"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["paas-monitor"]
}

resource "google_compute_health_check" "check" {
  name = "tcp-health-check"

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "80"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_backend_service" "service" {
  name             = "paas-monitor-backend"
  protocol         = "HTTP"
  port_name        = "paas-monitor"
  timeout_sec      = 10
  session_affinity = "NONE"

  backend {
    group = google_compute_instance_group_manager.group.instance_group
  }

  health_checks = [google_compute_health_check.check.self_link]
}

resource "google_compute_instance_template" "template" {
  name_prefix        = "appserver-template"
  description = "This template is used to create app server instances."

  tags = ["foo", "bar", "paas-monitor"]

  labels = {
    environment = "dev"
  }

  instance_description = "description assigned to instances"
  machine_type         = "n1-standard-1"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }

  // Use an existing disk resource
  # disk {
  #   // Instance Templates reference disks by name, not self link
  #   source      = google_compute_disk.foobar.name
  #   auto_delete = false
  #   boot        = false
  # }

  network_interface {
    network = "default"
  }

  metadata = {
    startup-script = file("custom-data.sh.tpl")
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "google_compute_image" "my_image" {
  family  = "debian-9"
  project = "debian-cloud"
}

resource "google_compute_disk" "foobar" {
  name    = "existing-disk"
  image   = data.google_compute_image.my_image.self_link
  size    = 10
  type    = "pd-ssd"
  zone    = var.zone
  project = var.project
}

resource "google_compute_instance_group_manager" "group" {
  name = "instance-group-manager"
  version {
    instance_template = google_compute_instance_template.template.self_link
  }
  base_instance_name = "instance-group-manager"
  zone               = var.zone
  target_size        = var.vm_count

  named_port {
    name = "paas-monitor"
    port = "80"
  }
}