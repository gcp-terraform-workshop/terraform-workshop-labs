# Terraform Modules

## Expected Outcome

In this challenge, first download a module from the HashiCorp Terraform Module Registry. Browse to,https://registry.terraform.io/modules/terraform-google-modules/network/google/2.3.0

Scroll down and copy the code under the "Usage" section and paste the code into a `main.tf` file. Make sure you modify the `project_id` with your project information. You can leave the rest unchanged for this lab. In the future, if you use a module from the registry you can modify the paremeters as needed. 

Run `terraform plan` to verify it looks correct, then run `terraform apply` to create the VPC. After review, you will need to run `terraform destroy` to remove the infrastructure that was just built.

# Part Two

Next you will create a module that contains a virtual machine deployment and then create an environment where you will call the module.

## How to

### Create Folder Structure

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/203-vm-module/`.

In order to organize your code, create the following folder structure and configuration files.

```hcl
└── module (folder)
    main.tf
    └── my_linux_vm
        └── main.tf
        └── firewall.tf
        └── provider.tf
        └──variables.tf
```

## Create the Module declaration in Root ##

In the root folder `main.tf` declare your module.

## The Module folder ##
Inside the `my_linux_vm` module folder there should be:

`provider.tf` file with the "google" provider information for your project.

In the `variables.tf` file you will need to create the following variables with the cooresponding paremeters. We will be using the `ubuntu-os-cloud/ubuntu-1910 image`

```hcl
variable "image" { default = "ubuntu-os-cloud/ubuntu-1910" }
variable "machine_name" ...
variable "zone" ...
variable "machine_count" ...
variable "environment" ...
variable "machine_type" ...
variable "machine_type_dev" ...

variable "name_count" ...

```

Next, in the `main.tf` file create your resources and use the appropriate variables that you created to populate the paremeters. Don't forget output paremeters for machine_type, name & zone.

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
The result should show this:

Plan: 6 to add, 0 to change, 0 to destroy.

Warning: Interpolation-only expressions are deprecated

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

Finally run `terraform apply` to create the VM. After review you will need to run `terraform destroy` to remove the infrastructure that was just built.

> Note: Feel free to apply this infrastructure to validate the workflow. Be sure to destroy when you are done.

