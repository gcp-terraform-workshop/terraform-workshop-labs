

resource "google_compute_firewall"  "allow_ssh" {
    name = "allow-ssh"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    target_tags = ["allow-ssh"]

}

resource "google_compute_firewall"  "allow_http" {
    name = "allow-http"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    target_tags = ["allow-http"]

}

resource "google_compute_firewall"  "allow_https" {
    name = "allow-https"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["443"]
    }

    target_tags = ["allow-https"]

}