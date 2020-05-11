# Azure Virtual Machine Scale Set

## Expected Outcome

In this challenge, you will create a basic kubernetes cluster from a module with 3 nodes each in a separate zones wihin the region.


## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/201-kubernetes/`.

We will start with a few of the basic resources needed.

You will need a `main.tf` file to hold our configuration and a `provider.tf` (copy from earlier lab).

First copy your `provider.tf` file into the folder.

Next let's go into the `main.tf` file and add the following code:

```hcl

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "YOUR PROJECT HERE"
  name                       = "gke-test-1"
  region                     = "us-east1"
  zones                      = ["us-east1-b", "us-east1-c", "us-east1-d"]
  network                    = "default"
  subnetwork                 = "default"
  ip_range_pods              = ""
  ip_range_services          = ""
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-2"
      min_count          = 1
      max_count          = 2  # quota errors if the number is too high
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = "true"
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }
  
  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
```
### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and validate all resources are being created as desired.

Run `terraform apply` and type `yes` when prompted.

Inspect the infrastructure in the portal.

Change the node count to another number and replan, does it match your expectations?

### Re-Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and validate all resources are being created as desired.

Run `terraform apply` and type `yes` when prompted.

Inspect the infrastructure in the portal.


### Clean up

When you are done, run `terraform destroy` to remove everything we created.
