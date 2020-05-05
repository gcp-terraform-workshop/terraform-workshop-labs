
## Introduction
In this lab you will deploy a sample Node.js application to App Engine using Terraform.

## Steps to follow
Using the portal do the following steps first:
  1. Create new GCP Project
  2. Create Service account in new project with Owner role
  3. Update Terraform.json with "key" for new credentials
  4. Enable Cloud Resource Manager API
  5. Enable App Engine Admin API

## Next, create the Teraform Configuration files/folders required:
Working folder should look like this:
    
    Files (folder)
    main.tf
    variables.tf
    terraform.json  
 
Change/create directory into a folder specific to this challenge.

For example: cd ~/TerraformWorkshop/208-app-engine

6. Create a new file called `main.tf` with the following contents. 

```hcl
provider "google" {
  credentials = file("terraform.json")
  project = var.gcp_project
}

data "google_project" "project" {}

resource "google_app_engine_application" "app" {
  project     = data.google_project.project.project_id
  location_id = "us-central"
}

resource "google_app_engine_standard_app_version" "myapp_v1" {
  version_id = "v1"
  service    = "default"
  runtime    = "nodejs10"
  project    = data.google_project.project.project_id

  entrypoint {
    shell = "node ./app.js"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/${google_storage_bucket_object.object.name}"
    }
  }

  env_variables = {
    port = "8080"
  }

  delete_service_on_destroy = true
}

resource "google_storage_bucket" "bucket" {
  name    = var.google_storage_bucket
  project = data.google_project.project.project_id

}

resource "google_storage_bucket_object" "object" {
  name   ="hello_world.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./file/hello_world.zip"
}
```

 7. Update project Id & Bucket Name in variables.tf 


 ```hcl
   variable "gcp_project" {
  default = "YOUR PROJECT NAME HERE"
  }

  variable "google_storage_bucket" {
  default = "YOUR BUCKET NAME HERE"
  }
  ```
  8. Copy the lab hello-world.zip file into the folder labled "file"

 9. Run terraform init
10. Run terraform plan
11. Run terraform apply

## Visit your app
Congratulations! Your app has been deployed. The default URL of your app is a subdomain on appspot.com that starts with your project's ID: YOUR PROJECT NAME.appspot.com.

Try visiting your deployed application.

## View your app's status
You can check in on your app by monitoring its status on the App Engine dashboard.

Open the Navigation menu in the upper-left corner of the console.

Then, select the App Engine section.

Disable your application
Go to the Settings page.

Click Disable Application.

This is sufficient to stop billing from this app. More details on the relationship between apps and projects and how to manage each can be found here.

## Delete your project
If you would like to completely delete the app, you must delete the project in the Manage resources page. This is not reversible, and any other resources you have in your project will be destroyed:

