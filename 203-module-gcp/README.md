# Terraform Modules

## Expected Outcome

In this challenge, first download a module from the HashiCorp Terraform Module Registry.Browse to,https://registry.terraform.io/modules/terraform-google-modules/network/google/2.3.0

Scroll down and copy the code under the "Usage" section and paste the code into a `main.tf` file. Make sure you modify the `project_id` with your project information. You can leave the rest un changed for this lab. In the future, if you use a module from the registry you can modify the paremeters as needed. 

 ```hcl
module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 2.3"

    project_id   = "<PROJECT ID>
    network_name = "example-vpc"
    routing_mode = "GLOBAL"

subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "us-west1"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-west1"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "This subnet has a description"
        },
        {
            subnet_name               = "subnet-03"
            subnet_ip                 = "10.10.30.0/24"
            subnet_region             = "us-west1"
            subnet_flow_logs          = "true"
            subnet_flow_logs_interval = "INTERVAL_10_MIN"
            subnet_flow_logs_sampling = 0.7
            subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
        }
    ]

    secondary_ranges = {
        subnet-01 = [
            {
                range_name    = "subnet-01-secondary-01"
                ip_cidr_range = "192.168.64.0/24"
            },
        ]

        subnet-02 = []
    }

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        },
        {
            name                   = "app-proxy"
            description            = "route through proxy to reach app"
            destination_range      = "10.50.10.0/24"
            tags                   = "app-proxy"
            next_hop_instance      = "app-proxy-instance"
            next_hop_instance_zone = "us-west1-a"
        },
    ]
}
```
run `terraform plan` to verify it looks correct, then run `terraform apply` to create the VPC. After review, you will need to run `terraform destroy` to remove the infrastructure that was just built.

## Part Two

Next you will create a module to contain a virtual machine deployment, then create an environment where you will call the module.

## How to

### Create Folder Structure

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/201-vm-module/`.

In order to organize your code, create the following folder structure and configuration files.

```hcl

└── modules
└── main.tf
└── my_linux_vm
        └── main.tf
        └── firewall.tf
        └── provider.tf
        └──variables.tf
```

### Create the Module declaration in Root

main.tf to declare your module, it could look similar to this:

```hcl
module "linux_machine" {
  source   = ".//modules/my_linux_vm"
}
```
### Create the Module folder
Inside the `my_linux_vm` module folder there should be:

`provider.tf` file with the following contents:
```hcl
provider "google" {
    project = "mimetic-pursuit-271713"
    region = "us-east1-c"
  }
```

`variables.tf` file with the following contents:
```hcl
variable "image" { default = "ubuntu-os-cloud/ubuntu-1910" }
variable "machine_name" { default = "lab"}
variable "zone" { default = "us-east1-c"}
variable "machine_count" { default = "1"}
variable "environment" {default = "production"}
variable "machine_type" {default =  "n1-standard-1" }
variable "machine_type_dev" {default = "n1-standard-4"}

variable "name_count" { default = ["server1", "server2", "server3"] }

```

`main.tf` file with the following contents:

```hcl

resource "google_compute_instance" "default" {
count = "${var.machine_count}"
name = var.machine_name
machine_type = "${var.machine_type}"
zone = "${var.zone}"
can_ip_forward = "false"
description = "This is our Virtual Machine"

    tags = ["webserver", "demo-lab", "dev"]  

boot_disk {
    initialize_params {
        image = "${var.image}"
        size  = "10"
    }
 }

labels = {
    name = "list-${count.index+1}"
    machine_type = "${var.environment != "dev" ? var.machine_type : var.machine_type_dev}"
}

network_interface {
    network = "default"
 }

metadata = {
    size = "20"
    foo = "bar"
}

metadata_startup_script = "echo hi > /test.txt"

service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
 }
  
}

resource "google_compute_disk" "default" {
    name = "test-desk"
    type = "pd-ssd"
    zone = var.zone
    size = "10"
}

resource "google_compute_attached_disk" "default" {
    disk = "${google_compute_disk.default.self_link}"
    instance = "${google_compute_instance.default[0].self_link}"
}
 
output "machine_type" { value = "${google_compute_instance.default.*.machine_type}" }
output "name" { value = "${google_compute_instance.default.*.name}" }
output "zone" { value = "${google_compute_instance.default.*.zone}" }

```


### Terraform Init

Run `terraform init`, you see see something like this:

```hcl
Initializing modules...
- module.linux_machine
  Getting source "./modules/my_linux_vm"
```

### Terraform Plan

Run `terraform plan`.

```hcl
          + network_ip         = (known after apply)
          + subnetwork         = (known after apply)
          + subnetwork_project = (known after apply)
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
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/compute.readonly",
              + "https://www.googleapis.com/auth/devstorage.read_only",
              + "https://www.googleapis.com/auth/userinfo.email",
            ]
        }
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Warning: Interpolation-only expressions are deprecated

  on my_linux_vm/main.tf line 3, in resource "google_compute_instance" "default":
   3: count = "${var.machine_count}"

Terraform 0.11 and earlier required all non-constant expressions to be
provided via interpolation syntax, but this pattern is now deprecated. To
silence this warning, remove the "${ sequence from the start and the }"
sequence from the end of this expression, leaving just the inner expression.

Template interpolation syntax is still used to construct strings from
expressions when the template includes multiple interpolation sequences or a
mixture of literal strings and interpolations. This deprecation applies only
to templates that consist entirely of a single interpolation sequence.

(and 5 more similar warnings elsewhere)

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

```

run `terraform plan` to verify it looks correct, then run `terraform apply` to create the VM. after review you will need to run `terraform destroy` to remove the infrastructure that was just built.

> Note: Feel free to apply this infrastructure to validate the workflow. Be sure to destroy when you are done.

