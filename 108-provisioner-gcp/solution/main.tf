//environment   = "PREFIX3"
variable "region" {
  default = "us-east1"
}
variable "project_id" {
  default = "booth-test-55"
}

variable "zone" {
  default = "us-east1-a"
}


variable "svc_acct_email" {
  default = "booth-insight-sa@booth-test-55.iam.gserviceaccount.com"
}
variable "user" {
  default = "ed.boykin"
}


terraform {
  backend "gcs" {
    bucket = "booth-demo-storage-bucket"
    prefix = "terraform/state108"

  }
}

provider "google" {
  region  = var.region
  zone    = var.zone
  project = var.project_id

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

  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/id_rsa.pub")}"
  }

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

  provisioner "file" {
    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = file("~/.ssh/id_rsa")
    }

    source      = "hello.py"
    destination = "hello.py"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "python3 -V",
      "sudo apt update",
      "sudo apt install -y python3-pip python3-flask",
      "python3 -m flask --version",
      "sudo FLASK_APP=hello.py nohup flask run --host=0.0.0.0 --port=8000 &",
      "sleep 1"
    ]
  }
}

output "app-URL" {
  description = "Public IP URL."
  value       = "http://${google_compute_instance.compute_instance.network_interface.0.access_config.0.nat_ip}:8000"
}
