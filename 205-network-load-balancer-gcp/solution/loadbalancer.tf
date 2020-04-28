resource "google_compute_forwarding_rule" "default" {
  project               = var.project_id
  name                  = "group1-lb"
  target                = google_compute_target_pool.default.self_link
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_target_pool" "default" {
  project          = var.project_id
  name             = "group1-lb"
  region           = "us-east1"
  session_affinity = "NONE"
}