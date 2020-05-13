
## Introduction
In this lab you will deploy a sample Node.js application to App Engine using Terraform.

## Steps to follow
Using the portal do the following steps first:
  1. Create new GCP Project
  2. Create Service Account in new project with "Owner" role
  3. Update `terraform.json` with "key" for new credentials
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

6. Create a new file called `main.tf` add the resources/parameters for Standard App Engine. 
7. Use the `variables.tf` file to add the project Id & bucket name in variables.tf 
8. Copy the lab hello-world.zip file into the folder labeled "file". (use the zip file provided in the solution/file folder)
9. Run terraform init
10. Run terraform plan
11. Run terraform apply

## Visit your app
Congratulations! Your app has been deployed. The default URL of your app is a subdomain on appspot.com that starts with your project's ID: YOUR_PROJECT_NAME.appspot.com.

Try visiting your deployed application.

## View your app's status
You can check in on your app by monitoring its status on the App Engine dashboard.

Open the Navigation menu in the upper-left corner of the console.

Then, select the App Engine section.

Disable your application
Go to the Settings page.

Click Disable Application.

This is sufficient to stop billing from this app. 

## Delete your project
If you would like to completely delete the app, you must delete the project in the Manage resources page. This is not reversible, and any other resources you have in your project will be destroyed:

