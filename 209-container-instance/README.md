# GCP Container Instance 
In this challenge, you will learn how to deploy a publically avalable container application using a module from a repository. THe configuration will include; Google Compute Engine instance in GCP, with an attached disk. Also includes SSH configuration, so a user can be provisioned on the fly for future logins.

- Create a VM for containers with Compute Engine.
- Create a HelloWorld container app.
- Run the container app on Compute Engine.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_metadata | Additional metadata to attach to the instance | map | `<map>` | no |
| client\_email | Service account email address | string | `""` | no |
| image | The Docker image to deploy to GCE instances | string | n/a | yes |
| image\_port | The port the image exposes for HTTP requests | string | n/a | yes |
| instance\_name | The desired name to assign to the deployed instance | string | `"disk-instance-vm-test"` | no |
| machine\_type | The GCP machine type to deploy | string | n/a | yes |
| project\_id | The project ID to deploy resource into | string | n/a | yes |
| restart\_policy | The desired Docker restart policy for the deployed image | string | n/a | yes |
| subnetwork | The name of the subnetwork to deploy instances into | string | n/a | yes |
| subnetwork\_project | The project ID where the desired subnetwork is provisioned | string | n/a | yes |
| zone | The GCP zone to deploy instances into | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| container | The container metadata provided to the module |
| http\_address | The IP address on which the HTTP service is exposed |
| http\_port | The port on which the HTTP service is exposed |
| instance\_name | The deployed instance name |
| ipv4 | The public IP address of the deployed instance |
| vm\_container\_label | The instance label containing container configuration |
| volumes | The volume metadata provided to the module |


## Expected Outcome
A containerized web application that is accessible on a public IP address using port 8080. 

# Create Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/209-container-instance/`.

Create a new file called `main.tf` with the following contents. Change the file information to reflect your credentials file for project access.

```hcl 

provider "google" {
    credentials = file("YOUR CREDENTIALS FILE")
}

locals {
  instance_name = format("%s-%s", var.instance_name, substr(md5(module.gce-container.container.image), 0, 8))
}

module "gce-container" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm.git"
 

  cos_image_name = var.cos_image_name

  container = {
    image = "gcr.io/google-samples/hello-app:1.0"

    env = [
      {
        name  = "TEST_VAR"
        value = "Hello World!"
      },
    ]

    volumeMounts = [
      {
        mountPath = "/cache"
        name      = "tempfs-0"
        readOnly  = false
      },
    ]
  }

  volumes = [
    {
      name = "tempfs-0"

      emptyDir = {
        medium = "Memory"
      }
    },
  ]

  restart_policy = "Always"
}

resource "google_compute_instance" "vm" {
  project      = var.project_id
  name         = local.instance_name
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  network_interface {
    subnetwork_project = var.subnetwork_project
    subnetwork         = var.subnetwork
    access_config {}
  }

  tags = ["container-vm-example"]

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
  }

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  service_account {
    email = var.client_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
```
Next add the `variables.tf` file below. Make the necessary changes in the first two blocks to reflect your project information;
```hcl


variable "project_id" {
  description = "The project ID to deploy resource into"
  default     = "YOUR PROJECT ID" 
}

variable "subnetwork_project" {
  description = "The project ID where the desired subnetwork is provisioned"
  default     = "YOUR PROJECT ID" 
}

variable "subnetwork" {
  description = "The name of the subnetwork to deploy instances into"
  default     = "default"
}

variable "instance_name" {
  description = "The desired name to assign to the deployed instance"
  default     = "disk-instance-vm-test"
}

variable "image" {
  description = "The Docker image to deploy to GCE instances"
 }

variable "image_port" {
  description = "The port the image exposes for HTTP requests"
}

variable "restart_policy" {
  description = "The desired Docker restart policy for the deployed image"
}

variable "machine_type" {
  description = "The GCP machine type to deploy"
}

variable "zone" {
  description = "The GCP zone to deploy instances into"
}

variable "additional_metadata" {
  type        = map(string)
  description = "Additional metadata to attach to the instance"
  default     = {}
}

variable "client_email" {
  description = "Service account email address"
  type        = string
  default     = ""
} 

variable "cos_image_name" {
  type   = string
  default = ""
}
```
Next we need to add a `tfvars file ` to override the module defaults with the information for your project. 

```hcl

  
  image            = "gcr.io/google-samples/hello-app:1.0"
  image_port       = "8080"
  machine_type     = "cos-stable-77-12371-89-0"
  restart_policy   = "Always"
  zone             = "us-east1-b"
  cos_image_name   = "cos-stable-77-12371-89-0"

```
Now add an `outputs.tf` file that will provide the information for you to verify/view your deployment after running `terraform apply`.

```hcl

output "vm_container_label" {
  description = "The instance label containing container configuration"
  value       = module.gce-container.vm_container_label
}

output "container" {
  description = "The container metadata provided to the module"
  value       = module.gce-container.container
}

output "volumes" {
  description = "The volume metadata provided to the module"
  value       = module.gce-container.volumes
}

output "http_address" {
  description = "The IP address on which the HTTP service is exposed"
  value       = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}

output "http_port" {
  description = "The port on which the HTTP service is exposed"
  value       = var.image_port
}

output "instance_name" {
  description = "The deployed instance name"
  value       = local.instance_name
}

output "ipv4" {
  description = "The public IP address of the deployed instance"
  value       = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}
```

## Terraform Init and Plan

Now that your configuration should be completed you will need to run `terraform init`. Upon successful initialization you will then run `terraform plan` to test deployment.


## Terraform Apply

Running a `terraform apply` should look just like the resluts from `terraform plan` except you are prompted for approval to apply your configuration.

Type 'yes' and let Terraform build your infrastructure.

## Review the resources

Now that you have successfully deployed the containerize application you should review the resources that were created. 

## Final step - Cleanup

Run a `terraform destroy` when you are done exploring.
