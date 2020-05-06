# Variables

## Expected Outcome

In this Lab you will use Terraform to create variables for your project. We will build on the concepts that you created in the last lab and convert a few of the hardcoded values into variables.


In this challenge, you will:

- Initialize Terraform
- Create a `variables` file
- Learn a few ways to use variables
- Run a `plan` to review Resources created
- Run an `apply` to create resources
- Run a `destroy` to remove the GCP infrastructure

## How To

### Create Terraform Configuration

Lets create a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/102-variables-gcp/`. 

### Defining Variables

Create a file named `variables.tf` and add the following lines;

```hcl

variable "project" {}

variable "credentials_file" {}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "us-east1-c"
}

```
Next create a file named `main.tf` and add the code below. The information to complete the variable defaults will come from different places. The 'project' variable will be manually entered on . The 'credentials' variable will come from an external file and the region & zone variables will use the defaults provided in the `variables.tf` file.

You should have the credentials json file that was created for the last lab. We will copy that into this folder so that you can authenticate properly to the project in this Lab.

```hcl
provider "google" {
  version = "3.5.0"
  credentials = file(var.credentials_file)
  project = var.project
  region  = var.region
  zone    = var.zone
  }

}
resource "google_storage_bucket" "my_storage_bucket" {
  name          = "my-demo-storage-bucket"
  location      = var.region
 }
}
```

Now create a file called `terraform.tfvars` with the following code;

```hcl
project = var.project
credentials_file = "service-account.json"

```
Note: For security reasons, Hashicorp recommends never saving secrets or usernames and passwords to version control. Your terraform configuration will probably need these secret values, though. One solution is to create a local secret variables file and use -var-file to load it.

```hcl
$ terraform apply \
  -var-file="secret.tfvars" \
``` 
The most common input types for variables used in Terraform code are:
 - Strings (Terraform default if not defined)
 - Numbers
 - Lists

Let's go back to our `variables.tf` file and provide the `type =` for the following variable names "project" to `number`.

```hcl
variable "project" {
  type = number
 }

```
Now run `terraform init` to initialize the folder.
Now lets run `terraform plan`. Notice that you get an error when you enter our project ID. 
```hcl
$ terraform plan

Error: Invalid value for input variable

  on terraform.tfvars line 1:
   1: project = "<PROJECT_ID>"

The given value is not valid for variable "project": a number is required. 
```
The `type = number` will not work for this variable since our actual value is alpha numeric. Let's change the variable `type` to `type = string` and re-run terraform plan.

```hcl
variable "project" {
  type = string
 }

```
This time provide the valid project name from GCP and Terraform will complete the request. 

### Lists and Maps
Let's create a `List` that identifies the `zones` in our region that we would like to create resources in and add it to the `variables.tf` file. 
 
```hcl
variable "zone" {
 type = list(string)
  default = ["us-east1-b","us-east1-c","us-east1-d"]
  } 
```

Since a list starts numbering at "0", if we used the following code in our `main.tf` file the zone would be set to us-east1-c.
```hcl
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone[1]
}

```
### Labels (Tags)
Lets add a Label to identify our environment. add the following to the resource block under the location attribute.
```hcl
  labels = {
    environment = "dev"
```
re-run terraform plan and then terraform apply to see the result.

### Things to remember for Variable precedent order
- Environment Variable
- Files (Variables.tf, terraform.tfvars or *.auto.tfvars)
- CLI input.