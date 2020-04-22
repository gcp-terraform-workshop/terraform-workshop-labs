In this lab you will implenent a common cloud pattern with Terraform to demonstate how terraform can make setting up these patters an simpler tasks

The first pattern you will create is a managed instance group. This is a collection of identical VMs that you define via an instance template and set scale on.


## Resources created 
google_compute_instance_template.default: The instance template assigned to the instance group.
google_compute_instance_group_manager: The instange group manager that uses the instance template and target pools.
google_compute_firewall: Firewall rule to allow ssh access to the instances.

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/103-basic-tf-configurations/`.

We will start with a few of the basic files needed.

Create a `main.tf` file to hold our configuration.
Create a `variables.tf` file to hold some variables to make our code cleaner.
Create a `terraform.tfvars` file to hold our variable values.

### Add base provider and terrafor config blocks

In `main.tf` add the same provider and terraform blocks from 101-connect-gcp.

```hcl
terraform {
  backend "gcs" {
    ...snip...  
  }
}

provider "google" {
    ...snip...  
}
```

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