# GCP Virtual machine

## Expected Outcome

In this challenge, you will create a GCP Virtual Machine and use the `custom_data` argument to provision a simple web app.

You will gradually add Terraform configuration to build all the resources needed to be able to login to the GCP Virtual Machine.

The resources you will use in this challenge:

- Compute Firewall
- Virtual Machine

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/101-custom-data/`.

We will start with a few of the basic resources needed.

Create a `main.tf` file to hold our configuration.

### Create Variables

Create a few variables that will help keep our code clean:

```hcl
variable "region" { 
    default = ""
    description = "GCP Region"
}
variable "project_id" {
    default = ""
    description = ""GCP Console project id"
}
variable "svc_acct_email" {
  default = ""
  description = "GCP Service account email. Formatis like: somethingsomething@appspot.gserviceaccount.com"
}
variable "user" {
  default =""
  description = "SSL Key username. Used to connect to VM"
}
```


### Create Virtual Machine Firewall

Create a VM firewall to allow access to the VM. This will allow incoming icmp protocol (ping)
and incoming tcp connections on ports 80, 8000, and 8080

```hcl
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
```

### Create the VM

Add the actual VM:

```hcl
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
    email = var.svc_acct_email 
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/gcpvmkey.pub")}"
  }

   metadata_startup_script = <<SCRIPT
#!/bin/bash

# Setup logging
logfile="/home/${var.admin_username}/custom-data.log"
exec > $logfile 2>&1

python3 -V
sudo apt update
sudo apt install -y python3-pip python3-flask
python3 -m flask --version

sudo cat << EOF > /home/${var.admin_username}/hello.py
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

chmod +x /home/${var.admin_username}/hello.py

sudo -b FLASK_APP=/home/${var.admin_username}/hello.py flask run --host=0.0.0.0 --port=8000
SCRIPT

}
```

> Note: Carefully look at the `metadata_startup_script` argument, especially how there are variable inserts into the script.

### Add an Output

Create an output that will allow for easy navigation to the web app:

```hcl
output "app-URL" {
  description = "Public IP URL."
  value       = "http://${google_compute_instance.compute_instance.network_interface.0.access_config.0.nat_ip}:8000"
}
```

### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` where you should see the plan of all the new resources.

Run `terraform apply` to create all the infrastructure.

After a successful apply, navigate to the listed URL to see the web app.

### Clean up

When you are done, run `terraform destroy` to remove everything we created.

## Advanced areas to explore

1. Convert the inline `metadata_startup_script` script to use the [Terraform Template](https://www.terraform.io/docs/providers/template/d/file.html) data resource.
2. Create additional customization of the `metadata_startup_script` script to pass in your own "src" image URL.
