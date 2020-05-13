## Google Network Load Balancer

In this lab you are going to build a network load balancer using another common cloud pattern with Terraform . To demonstrate how easy it is to extend a terraform model, you will be building the load balancer on top of the model you built in lab 204-vm-instance-group.

## New Resources Created 
- google_compute_forwarding_rule: 
- google_compute_target_pool

## How to

### Create the base Terraform Configuration

Change directory into a folder specific to this challenge.

For example: `cd ~/TerraformWorkshop/205-network-load-balancer/`.

First, copy your solution from 204-vm-instance-group-gcp. 

Create a new file name `loadbalancer.tf` file to hold our load balancer configuration.

## Add Configuration for Load Balancer

In your `loadbalancer.tf` file, add the new resources required to configure the resource.

## Update main.tf

In `main.tf` we need to update the `google compute instance manager` so the instance manager knows that it is part of a load balancer target pool. Update the `google_compute_instance_group_manager`  by adding the following argument and value

```hcl
  target_pools = ...
```

### Run Terraform Workflow

Run `terraform init` since this is the first time we are running Terraform from this directory.

Run `terraform plan` and check that everything is entered correctly. Your output should produce a result similar to below. If your output shows fewer resources being created, (there should be six), then you may not have run 'terraform destroy' after finishing up lab 204. Please go back to the lab 204 folder and run `terraform destroy` now.

```hcl

Plan: 6 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed 
"terraform apply" is subsequently run.
```

Run `terraform apply` to create all the infrastructure.

Once the run completes you should see output similar to this;

```hcl
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

external_ip = XXX.XXX.XXX.XXX
target_pool = https://www.googleapis.com/compute/v1/projects/...
```

The `external_ip' is the public ip address of your new load balancer. In few minutes, you will be able to test it. However, it takes a while for the instance group to fully spin up and the startup script to execute.

Open a browser and navigate to your GCP console. Once logged in, go to the Computer Engine | Instance Groups section.
![](img/Img1.png)

Once there click on your new instance group to view the details. The instances will initially show a status of being 'verified'. You need to wait until this is complete and the console shows this:
![](img/Img2.png)

Now, you can load the external ip address in a new browser window navigate to the site to see some cute kittens!

`http://<external ip>:8000`

### Clean up

When you are done, run `terraform destroy` to remove everything we created.

## Advanced areas to explore

1. Change the instance count on `google_compute_instance_group_manager` 
2. Change other parameters to see how the instances change [Google Compute Instance Manager](https://www.terraform.io/docs/providers/google/r/compute_instance_group_manager.html) data resource.
3. Look at other options for load balancing and forwarding.  [Google Compute Forwarding Rule](https://www.terraform.io/docs/providers/google/r/compute_forwarding_rule.html). Try limiting the forwarding to only port 8000.

