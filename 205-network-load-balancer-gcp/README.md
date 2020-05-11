## Google Network Load Balancer

In this lab you are going to build a network load balancer using another common cloud pattern with Terraform . To deomonstrate how easy it is to extend a terraform model, you will be building the load balancer on top of the model you built in lab 204-vm-instance-group.

## New Resources Created 
- google_compute_forwarding_rule: 
- google_compute_target_pool

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/205-network-load-balancer/`.

First, copy your solution from 204-vm-instance-group-gcp. 

Create a new file name `loadbalancer.tf` file to hold our load balancer configuration.


## Add Configuration for Load Balancer

In your `loadbalancer.tf` file, add the following new resources

```hcl
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
```

## Update main.tf

In `main.tf' we need to update the google compute instance manager so the instance manager knows that it is part of a load balancer target pool.
In `main.tf' update the google_compute_instance_group_manager by adding the following argument and value

```hcl
  target_pools = [google_compute_target_pool.default.self_link]
```

### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and check that everything is entered correctly. Your output should look similar to this. If you output shows fewer resources being created, there should be six, then you may not have run 'terraform destroy' after finishing up lab 204. Please go back to the lab 204 folder and run `terraform destroy` now.

```hcl
terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_firewall.default will be created
  + resource "google_compute_firewall" "default" {
      + creation_timestamp = (known after apply)
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + id                 = (known after apply)
      + name               = "default-firewall"
      + network            = "default"
      + priority           = 1000
      + project            = (known after apply)
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]

      + allow {
          + ports    = [
              + "80",
              + "8000",
              + "8080",
            ]
          + protocol = "tcp"
        }
      + allow {
          + ports    = []
          + protocol = "icmp"
        }
    }

  # google_compute_forwarding_rule.default will be created
  + resource "google_compute_forwarding_rule" "default" {
      + creation_timestamp    = (known after apply)
      + id                    = (known after apply)
      + ip_address            = (known after apply)
      + ip_protocol           = (known after apply)
      + ip_version            = (known after apply)
      + load_balancing_scheme = "EXTERNAL"
      + name                  = "group1-lb"
      + network               = (known after apply)
      + network_tier          = (known after apply)
      + project               = "dazzling-mantra-271319"
      + region                = (known after apply)
      + self_link             = (known after apply)
      + service_name          = (known after apply)
      + subnetwork            = (known after apply)
      + target                = (known after apply)
    }

  # google_compute_health_check.mig-health-check will be created
  + resource "google_compute_health_check" "mig-health-check" {
      + check_interval_sec  = 30
      + creation_timestamp  = (known after apply)
      + healthy_threshold   = 1
      + id                  = (known after apply)
      + name                = "my-instance-group-hc"
      + project             = "dazzling-mantra-271319"
      + self_link           = (known after apply)
      + timeout_sec         = 10
      + type                = (known after apply)
      + unhealthy_threshold = 10

      + http_health_check {
          + port         = 8000
          + proxy_header = "NONE"
          + request_path = "/"
        }
    }

  # google_compute_instance_group_manager.default will be created
  + resource "google_compute_instance_group_manager" "default" {
      + base_instance_name = "base-instance"
      + description        = "compute VM Instance Group"
      + fingerprint        = (known after apply)
      + id                 = (known after apply)
      + instance_group     = (known after apply)
      + instance_template  = (known after apply)
      + name               = "my-default-instance-group"
      + project            = "dazzling-mantra-271319"
      + self_link          = (known after apply)
      + target_pools       = (known after apply)
      + target_size        = 2
      + update_strategy    = (known after apply)
      + wait_for_instances = false
      + zone               = "us-east1-b"

      + auto_healing_policies {
          + health_check      = (known after apply)
          + initial_delay_sec = 30
        }

      + named_port {
          + name = "http"
          + port = 80
        }

      + update_policy {
          + max_surge_fixed         = (known after apply)
          + max_surge_percent       = (known after apply)
          + max_unavailable_fixed   = (known after apply)
          + max_unavailable_percent = (known after apply)
          + min_ready_sec           = (known after apply)
          + minimal_action          = (known after apply)
          + type                    = (known after apply)
        }

      + version {
          + instance_template = (known after apply)
        }
    }

  # google_compute_instance_template.default will be created
  + resource "google_compute_instance_template" "default" {
      + can_ip_forward          = false
      + id                      = (known after apply)
      + machine_type            = "n1-standard-1"
      + metadata_fingerprint    = (known after apply)
      + metadata_startup_script = <<~EOT
            #!/bin/bash

            # Setup logging
            logfile="/tmp/custom-data.log"
            exec > $logfile 2>&1

            python3 -V
            sudo apt update
            sudo apt install -y python3-pip python3-flask
            python3 -m flask --version

            sudo cat << EOF > /tmp/hello.py
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

            chmod +x /tmp/hello.py

            sudo -b FLASK_APP=/tmp/hello.py flask run --host=0.0.0.0 --port=8000
        EOT
      + name                    = (known after apply)
      + name_prefix             = "default-"
      + project                 = "dazzling-mantra-271319"
      + region                  = "us-east1"
      + self_link               = (known after apply)
      + tags                    = [
          + "allow-service",
        ]
      + tags_fingerprint        = (known after apply)

      + disk {
          + auto_delete  = true
          + boot         = true
          + device_name  = (known after apply)
          + disk_type    = "pd-ssd"
          + interface    = (known after apply)
          + mode         = "READ_WRITE"
          + source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
          + type         = "PERSISTENT"
        }

      + network_interface {
          + name               = (known after apply)
          + network            = "default"
          + subnetwork         = "default"
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip                 = (known after apply)
              + network_tier           = (known after apply)
              + public_ptr_domain_name = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = true
          + on_host_maintenance = (known after apply)
          + preemptible         = false
        }

      + service_account {
          + email  = "dazzling-mantra-271319@appspot.gserviceaccount.com"
          + scopes = [
              + "https://www.googleapis.com/auth/compute.readonly",
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/userinfo.email",
            ]
        }
    }

  # google_compute_target_pool.default will be created
  + resource "google_compute_target_pool" "default" {
      + id               = (known after apply)
      + instances        = (known after apply)
      + name             = "group1-lb"
      + project          = "dazzling-mantra-271319"
      + region           = "us-east1"
      + self_link        = (known after apply)
      + session_affinity = "NONE"
    }

Plan: 6 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Run `terraform apply` to create all the infrastructure.

Once the run completes you should see output similar to this;

```hcl
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

external_ip = 35.229.46.153
target_pool = https://www.googleapis.com/compute/v1/projects/dazzling-mantra-271319/regions/us-east1/targetPools/group1-lb
```

The `external_ip' is the public ip address of yoru new load balancer. In few minutes, you will be able to test it. However, it takes a while for the instance group to fully spin up and the startup script to execute.

Open a browser and navigate to your GCP console. Once logged in, hgo to the Computer Engine | Instance Groups section.
![](img/Img1.png)

Once there click on your new instance group to view the details. The instances will initially show a status of being 'verified'. You need to wait until this is complete and the console shows this:
![](img/Img2.png)

Now, you can load the external ip address in a new browser window navigate to the site to see some cute kittens!

`http://<external ip>:8000`

### Clean up

When you are done, run `terraform destroy` to remove everything we created.

## Advanced areas to explore

1. Change the instance count on `google_compute_instance_group_manager` 
2. Change other parameters to see how the instances change [Google Compute Instance Manager](https://www.terraform.io/docs/providers/google/r/compute_instance_group_manager.html) data resource.
3. Look at other options for load balancing and forwarding.  [Google Compute Forwarding Rule](https://www.terraform.io/docs/providers/google/r/compute_forwarding_rule.html). Try limiting the forwarding to only port 8000.

