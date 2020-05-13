# Azure Virtual Machine Scale Set

## Expected Outcome

In this challenge, you will create a basic kubernetes cluster from a module with 3 nodes each in a separate zones wihin the region.


## How to

## Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/201-kubernetes/`.

We will start with a few of the basic resources needed.

You will need a `main.tf` file to hold our configuration and a `provider.tf` (copy from earlier lab).

First copy your `provider.tf` file into the folder.

Next go into the `main.tf` file and add Kubernetes-engine module code.

## Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and validate all resources are being created as desired.

Run `terraform apply` and type `yes` when prompted.

Inspect the infrastructure in the portal.

Change the node count to another number and replan, does it match your expectations?

## Re-Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and validate all resources are being created as desired.

Run `terraform apply` and type `yes` when prompted.

Inspect the infrastructure in the portal.


## Clean up

When you are done, run `terraform destroy` to remove everything we created.
