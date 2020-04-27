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
  default = "ed.boykin"
}


terraform {
  backend "gcs" {
    credentials = "../../dazzling-mantra-271319-bcb28c004aed.json"
    bucket      = "my-demo-storage-bucket"
    prefix      = "terraform/state"

  }
}

provider "google" {
  credentials = file("../../dazzling-mantra-271319-bcb28c004aed.json")
  region      = "us-east1"
  zone        = "us-east1-a"
  project     = "dazzling-mantra-271319"

}

resource "google_compute_firewall" "default" {
  name    = "default-firewall"
  network = "default"

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
    email  = var.svc_acct_email
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/gcpvmkey.pub")}"
  }

  metadata_startup_script = <<SCRIPT
#!/bin/bash

# Setup logging
logfile="/home/${var.user}/custom-data.log"
exec > $logfile 2>&1

python3 -V
sudo apt update
sudo apt install -y python3-pip python3-flask
python3 -m flask --version

sudo cat << EOF > /home/${var.user}/hello.py
from flask import Flask
import requests

app = Flask(__name__)

import requests
@app.route('/')
def hello_world():
    return """<!DOCTYPE html>
<html>
<head>
    <title>Kittens</title>
</head>
<body>
    <img src="http://placekitten.com/200/300" alt="User Image">
</body>
</html>"""
EOF

chmod +x /home/${var.user}/hello.py

sudo -b FLASK_APP=/home/${var.user}/hello.py flask run --host=0.0.0.0 --port=8000
SCRIPT

}

output "app-URL" {
  description = "Public IP URL."
  value       = "http://${google_compute_instance.compute_instance.network_interface.0.access_config.0.nat_ip}:8000"
}
