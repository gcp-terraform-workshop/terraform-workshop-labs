# Using Terraform Provisioner

## Expected Outcome

In this challenge, you will create a GCP Virtual Machine but this time layer in Terraform Provisioners to configure the machines as part the Terraform apply.

## Background

Terraform [provisioners](https://www.terraform.io/docs/provisioners/index.html) help you do additional setup and configuration when a resource is created or destroyed. You can move files, run shell scripts, and install software.

Provisioners are not intended to maintain desired state and configuration for existing resources. For that purpose, you should use one of the many tools for configuration management, such as [Chef](https://www.chef.io/chef/), [Ansible](https://www.ansible.com/), etc. (Terraform includes a [chef](https://www.terraform.io/docs/provisioners/chef.html) provisioner.)

An imaged-based infrastructure, such as images created with [Packer](https://www.packer.io), can eliminate much of the need to configure resources when they are created. In this common scenario, Terraform is used to provision infrastructure based on a custom image. The image is managed as code.

## How To

### First step, create an SSH key with SSH-KEYGEN to use to connect to a GCP VM instance
This site explains how to create the ssh key you need.
[ssh Keygen](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys#linux-and-macos)


### Defining a provisioner

Provisioners are defined on resources, most commonly a new instance of a virtual machine or container.

The complete configuration for this example is given below. By now, you should be familiar with most of the contents.

Notice that the google_compute_instance resource contains two provisioner blocks:

```hcl
resource "google_compute_instance" "compute_instance" {

    <...snip...>

   provisioner "file" {
    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type     = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = file("~/.ssh/gcpvmkey")
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
      private_key = file("~/.ssh/gcpvmkey")
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
```

As this example shows, you can define more than one provisioner in a resource block. The [file](https://www.terraform.io/docs/provisioners/file.html) and [remote-exec](https://www.terraform.io/docs/provisioners/remote-exec.html) providers are used to perform two simple setup tasks:

-   File copies a python file from the machine that is running Terraform to the new VM instance.
-   Remote-exec runs commands to start a python flask app.

Both providers need a [connection](https://www.terraform.io/docs/provisioners/connection.html) to the new virtual machine to do their jobs. 
The SSH key you created earlier needs to set. The public key should be specified on the vm ssh-keys block and the private key file on the two provisions blocks.

### Running provisioners

Provisioners run when a resource is created, or a resource is destroyed. Provisioners do not run during update operations. The example configuration for this section defines two provisioners that run only when a new virtual machine instance is created. If the virtual machine instance is later modified or destroyed, the provisioners will not run.

Although we don't show it in the example configuration, there is a way to define provisioners that run when a resource is destroyed.

The full configuration is:

```hcl
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
  default ="ed.boykin"
}


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

// A single Google Cloud Engine instance
resource "google_compute_instance" "compute_instance" {
  name         = "gcp-vm"
  machine_type = "n1-standard-1"
  zone         = "${var.region}-b"

  metadata = {
    ssh-keys = "${var.user}:${file("~/.ssh/gcpvmkey.pub")}"
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
    email = var.svc_acct_email 
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

 provisioner "file" {
    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type     = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = file("~/.ssh/gcpvmkey")
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
      private_key = file("~/.ssh/gcpvmkey")
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

```

To run the example configuration with provisioners:

1.  Copy the configuration to a file named `main.tf`. It should be the only `.tf` file in the folder.
2.  Create a file named `hello.py`.
    1.  In the editor, add the following text: 
    ```py
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
    ``` 
    2.  Save the file and close the editor.
3.  Run `terraform init`
4.  Run `terraform plan`
5.  Run `terraform apply`. When prompted to continue, answer `yes`.


Continue the procedure from above by doing the following:

1.  Run `terraform show` to examine the current state.
2.  Update the image src in the flask app to return a different image (Look for "http://placekitten.com/200/300").
3.  Update your provisioner text file and run a `terraform plan`. Were the results as expected?

### Clean up

When you are done, run `terraform destroy` to remove everything we created

### Failed provisioners and tainted resources

Provisioners sometimes fail to run properly. By the time the provisioner is run, the resource has already been physically created. If the provisioner fails, the resource will be left in an unknown state. When this happens, Terraform will generate an error and mark the resource as "tainted." A resource that is tainted isn't considered safe to use.

When you generate your next execution plan, Terraform will not attempt to restart provisioning on the tainted resource because it isn't guaranteed to be safe. Instead, Terraform will remove any tainted resources and create new resources, attempting to provision them again after creation.

You might wonder why Terraform doesn't destroy the tainted resource during apply, to avoid leaving a resource in an unknown state. Terraform doesn't roll back tainted resources because that action was not in the execution plan. The execution plan says that a resource will be created, but not that it might be deleted. If you create an execution plan with a tainted resource, however, the plan will clearly state that the resource will be destroyed because it is tainted.


### Destroy Provisioners

Provisioners can also be defined that run only during a destroy operation. These are known as [destroy-time provisioners](https://www.terraform.io/docs/provisioners/index.html#destroy-time-provisioners). Destroy provisioners are useful for performing system cleanup, extracting data, etc.

The following code snippet shows how a destroy provisioner is defined:

```
provisioner "remote-exec" {
    when = "destroy"

    <...snip...>

```
