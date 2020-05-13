# GCP Container Instance 
In this challenge, you will learn how to deploy a publicly avalable container application using a module from a repository. The configuration will include; "Simple-Instance" Google Compute Engine instance in GCP, with an attached disk. Also includes SSH configuration, so a user can be provisioned on the fly for future logins.

## How to 
- Create a `main.tf
- Create a variables.tf
- tfvars file to override the module defaults with the information for your project
- Create a `outputs.tf` file 
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
A containerized web application that is accessible on a public IP address. 

# Create Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/209-container-instance/`.

Create a new file called `main.tf` use the following Git Repository as an example: `https://github.com/terraform-google-modules/terraform-google-container-vm/tree/master/examples/simple_instance`

Next add the `variables.tf` file including the Input variables above.

Next we need to add a `tfvars file `. 

Now add an `outputs.tf` file that will provide the information for you to verify/view your deployment after running `terraform apply`.

## Terraform Init and Plan

Now that your configuration should be completed you will need to run `terraform init`. Upon successful initialization you will then run `terraform plan` to test deployment.


## Terraform Apply

Running a `terraform apply` should look just like the results from `terraform plan` except you are prompted for approval to apply your configuration.

Type 'yes' and let Terraform build your infrastructure.

## Review the resources

Now that you have successfully deployed the containerize application you should review the resources that were created. 

## Final step - Cleanup

Run a `terraform destroy` when you are done exploring.
