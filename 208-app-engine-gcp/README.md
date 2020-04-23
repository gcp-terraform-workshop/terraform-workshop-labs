## Introduction
This tutorial shows you how to deploy a sample application to App Engine using the gcloud command.

Here are the steps you will be taking.

Create a project

Projects bundle code, VMs, and other resources together for easier development and monitoring.

Build and run your "Hello, world!" app

You will learn how to run your app using Cloud Shell, right in your browser. At the end, you'll deploy your app to the web using the gcloud command.

After the tutorial...

Your app will be real and you'll be able to experiment with it after you deploy, or you can remove it and start fresh.

## 
Begin by creating a new project or selecting an existing project for this tutorial.

clone the sample code
Use Cloud Shell to clone and navigate to the "Hello World" code. The sample code is cloned from your project repository to the Cloud Shell.

Note: If the directory already exists, remove the previous files before cloning.

git clone \
    https://github.com/GoogleCloudPlatform/golang-samples
Then, switch to the tutorial directory:

cd \
    golang-samples/appengine/go11x/h

    Configuring your deployment
You are now in the main directory for the sample code. We'll look at the files that configure your application.

Exploring the application
Enter the following command to view your application code:

cat helloworld.go
Exploring your configuration
App Engine uses YAML files to specify a deployment's configuration. app.yaml files contain information about your application, like the runtime environment, URL handlers, and more.

Enter the following command to view your configuration file:

cat app.yaml

----
## Testing your app
Test your app on Cloud Shell
Cloud Shell lets you test your app before deploying to make sure it's running as intended, just like debugging on your local machine.

To test your app enter the following:

go run .
Preview your app with "Web preview"
Your app is now running on Cloud Shell. You can access the app by clicking the Web preview  button at the top of the Cloud Shell pane and choosing Preview on port 8080.

## Deploying to App Engine
Create an application
To deploy your app, you need to create an app in a region:

gcloud app create
Note: If you already created an app, you can skip this step.

Deploying with Cloud Shell
You can use Cloud Shell to deploy your app. To deploy your app enter the following:

gcloud app deploy
Visit your app
Congratulations! Your app has been deployed. The default URL of your app is a subdomain on appspot.com that starts with your project's ID: terraform-containers.appspot.com.

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

