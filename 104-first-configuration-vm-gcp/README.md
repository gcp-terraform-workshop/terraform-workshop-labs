# GCP Virtual Machine

## Expected Outcome

In this challenge, you will create a GCP Virtual Machine running Ubuntu Linux.

The resources you will use in this challenge:

- Compute Firewall
- Compute Instance (VM)

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

We will start with a few of the basic resources needed.

Create a `main.tf` file to hold our configuration.
Create a `variables.tf` file to hold some variables to make our code cleaner.
Create a `terraform.tfvars` file to hold our variable values.

### Create Variables

In variables.tf define the following variables that will help keep our code clean:

```hcl
variable "project_id" {
    description = "The GCP project id where the resources will be created"
    type = string
}

variable "region" {
    default = "us-east1"
    description = "GCP region the resources will be created in"
    type = string
}

variable "svc_acct_email" {
    default = ""
    description = "email account for VM service account"
    type = string
}
```

### Settings the Variable Values

In terraform.tfvars set values for the variables you defined in variables.tf
```hcl
region = "us-east1"
project_id = "[set this to the project id from 101-connect-gcp]"
svc_acct_email = "[set this to the project email address from 101-connect-gcp]"

```

### Create Terraform config

With your variables setup, you can now begin to create the terraform ocnfiguration, you will do this in main.tf

### Add provider and terraform blocks.

Add the terraform and provider blocks from 101-connect-gcp. These will be resused in most of the labs today

```hcl
terraform {
  backend "gcs" {
    <snip...>
  }
}

provider "google" {
  <snip...>
}
```

### Create a Compute Firewall

A VM needs a firewall to allow and restrict traffic into and our of the VM. You do this with a google_compute_firewall resource.
This firewall is configured to allow inbound icmp (ping) traffic and tcp traffi con port 80 only but form any source ip address.
Additionally, it will be created inside the default VCP network that exists in every GCP project.

```hcl
resource "google_compute_firewall" "default" {
  name       = "default-firewall"
  network    = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}

}
```

### Create Virtual Machine

Now that we have a firewall in place, we will add a Virtual Machine.
We will create a VM with an GCP Image for Ubuntu 18.04.
Note that the network interface is, like the firewall, set to 'default'

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
}
```


### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` where you should see the plan of two new resources, namely the Resource Group and the Virtual Network.

<details><summary>View Output</summary>
<p>

```sh
$ terraform plan

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
              + "8080",
            ]
          + protocol = "tcp"
        }
      + allow {
          + ports    = []
          + protocol = "icmp"
        }
    }

  # google_compute_instance.compute_instance will be created
  + resource "google_compute_instance" "compute_instance" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "n1-standard-1"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "gcp-vm"
      + project              = (known after apply)
      + self_link            = (known after apply)
      + tags_fingerprint     = (known after apply)
      + zone                 = "us-east1-b"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "ubuntu-os-cloud/ubuntu-1804-lts"
              + labels = (known after apply)
              + size   = (known after apply)
              + type   = (known after apply)
            }
        }

      + network_interface {
          + name               = (known after apply)
          + network            = "default"
          + network_ip         = (known after apply)
          + subnetwork         = (known after apply)
          + subnetwork_project = (known after apply)

          + access_config {
              + nat_ip       = (known after apply)
              + network_tier = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart   = (known after apply)
          + on_host_maintenance = (known after apply)
          + preemptible         = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
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

Plan: 2 to add, 0 to change, 0 to destroy.
```

</p>
</details>

If your plan looks good, go ahead and run `terraform apply` and type "yes" to confirm you want to apply.
When it completes you should see:

```sh
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

### Outputs

You now have all the infrastructure in place and can now SSH into the Linux Server VM we just stood up.

But wait, the Public IP was dynamically created, how do I access it?

You could check the value in the GCP Console, however let's instead add outputs to get that information.

Create a new file named outputs.tf and in that file put the following block. 
Add the following output:

```hcl
output "public_ip" {
    value = google_compute_instance.compute_instance.network_interface.0.access_config.0.nat_ip
}

```

Now run a `terraform refresh`, which will refresh your state file with the real-world infrastructure and resolve the new outputs you just created.

The output should look similar to this:

```sh
$ terraform refresh
google_compute_firewall.default: Refreshing state... [id=projects/dazzling-mantra-271319/global/firewalls/default-firewall]
google_compute_instance.compute_instance: Refreshing state... [id=projects/dazzling-mantra-271319/zones/us-east1-b/instances/gcp-vm]

Outputs:

public_ip = 35.237.230.231
```

> Note: you can also run `terraform output` to see just these outputs without having to run refresh again.


### Scaling the Virtual Machine (extra credit)

Utilize the [count meta arguemnt](https://www.terraform.io/intro/examples/count.html) to allow for the scaling of VM's.

### Clean up

When you are done, run `terraform destroy` to remove everything we created.

## Advanced areas to explore

1. Extract secrets into required variables.
2. Add a data disk.
3. Add a DNS Label to the Public IP Address.
4. Search for other VM Images.
