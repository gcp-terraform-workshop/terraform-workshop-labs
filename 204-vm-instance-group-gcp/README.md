In this lab you will implement a common cloud pattern with Terraform. To demonstate how terraform can make setting up multiple instances a simpler task using patterns let's start first with the pattern you will need to create for the managed instance group. This is a collection of identical VMs that you define via an instance template and set scale on.

## Resources created 
- *google_compute_instance_template*: The instance template assigned to the instance group.
- *google_compute_instance_group_manager*: The instange group manager that uses the instance template and target pools.
- *google_compute_health_check*: Monitors the status of each instance VM
- *google_compute_firewall*: Firewall rule to allow ssh access to the instances.

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/103-basic-tf-configurations/`.

We will start with a few of the basic files needed.

Create a `main.tf` file to hold our configuration.
Create a `variables.tf` file to hold some variables to make our code cleaner.
Create a `terraform.tfvars` file to hold our variable values.

### Add base provider and terrafor config blocks

In `main.tf` add a provider block and terraform block.

### Create Variables

In variables.tf define the following variables that will help keep our code clean:
- project_id
- region
- svc_acct_email
```
### Settings the Variable Values

In terraform.tfvars, set values for the variables you defined in variables.tf

### Create Terraform config

With your variables setup, you can now begin to create the terraform configuration, you will do this in `main.tf`

### Add compute instance template.

In previous labs, you have created a single virtual machine. Now, you are going to define a template from which many identical virtual machines can be created.

Add a template block to your main.tf file. also, copy the `vm_startup.txt` file from 201-common-providers-gcp lab into the same folder. 

Go ahead and run `terraform plan` and check that everything is entered correctly. Your output should look similar to this

```hcl
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ...

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

The next resource you need to create is the managed instance group manager. This resource defines the setup for the configuration of your group of virtual machines. You will also create a basic health check or `auto_healing` policy to check on the operational status of each VM instance.

Once again, please put this code into your `main.tf file`.

Finally, you need to create a google_compute_health_check and a google_compute_firewall.
The health check is a monitoring resource the will regularly check an http address on each vm to see if it gets a response. In a production system, you would set automated reactions to failures on the health checks based on your business needs.
The firewall is similar to other firewalls you've already created in previous labs.

### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` where you should see the plan of all the new resources.

Run `terraform apply` to create all the infrastructure.

It takes a while for the instance group to fully spin up and the startup script to execute.

Open a browser and navigate to your good console. Once logged in, head over to the Computer Engine | Instance Groups section.
![](img/Img1.png)

Once there click on your new instance group to view the details. The instances will initially show a status of being 'verified'. You need to wait until this is complete and the console shows this:
![](img/Img2.png)

Now, you can copy either external ip address and in a new browser window navigate to the following site to see some cute kittens!

`http://<external ip>:8000`

### Clean up

When you are done, run `terraform destroy` to remove everything we created.

## Advanced areas to explore

1. Change the instance count on `google_compute_instance_group_manager` 
2. Change other parameters to see how the instances change [Google Compute Instance Manager](https://www.terraform.io/docs/providers/google/r/compute_instance_group_manager.html) data resource.

