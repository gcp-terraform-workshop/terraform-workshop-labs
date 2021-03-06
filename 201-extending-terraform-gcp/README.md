# Extending Terraform

## Expected Outcome

In this challenge, you will use non cloud specific providers to assist in containing common tasks within Terraform.

## How to

### Create Folder Structure

Change directory into a folder specific to this challenge.

Create a  `main.tf` file, we will add to this file as we go.

### Random Generator

First create a random password string and use an "output" to display the results. 

Run `terraform init`,

Run `terraform apply -auto-approve`.


output should look simular to this:
```hcl
Outputs:

password = USCx=<D(7+KVWu:o
```

Next add a "random guid" to the configuration. After Apply your output should look simular to this now;

```hcl
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

guid = 84502be0-13fc-4a49-ce02-4ab4e1b493ca
password = USCx=<D(7+KVWu:o
```

> Note: The password was NOT regenerated, why is this?


Now **update** the `random_guid` resource to use a "keepers" arguement:

Run `terraform apply -auto-approve` several times in a row. **What happens to the guid output?**

### SSH Public/Private Key Generator

Now you will add configuration for Terraform to generate public/private SSH keys (rsa), dynamically.

Run `terraform init`,

Run `terraform apply -auto-approve`.

output should look simular to below;

```hcl
Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

Outputs:

guid = ad4efda0-d17d-559c-5cfe-1ed3ab9ce86b
password = USCx=<D(7+KVWu:o
```

This is great, but we want the keys as files, how?

Hint: You will need to use the local-exec provider to change permissions 

What is this "local-exec"?

If you have too wide of permissions on a private SSH key, you can see the following error when trying to use that key to access a remote system:

```sh
Permissions 0777 for './id_rsa.pem' are too open.
It is recommended that your private key files are NOT accessible by others.
This private key will be ignored.
```

Add the `local exec` configuration so it will run a `chmod` on the file after it is created.

Run `terraform init`,

Run `terraform apply -auto-approve`.

You should now have two new files in your current working directory.

Next, let's delete one of the files (i.e. `rm id_rsa.pem`).

- Run a `terraform plan`, what changes (if any) are needed? Is this what you expected?
- Run `terraform apply -auto-approve` **What happend?**

### Clean up

When you are done, run `terraform destroy` to remove everything (including your local files).
