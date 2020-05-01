provider "google" {
  credentials = file("terraform.json")
  project = "neon-feat-275918"
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
  name    = "insight20eb4"
  project = data.google_project.project.project_id

}

resource "google_storage_bucket_object" "object" {
  name   ="hello_world.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./file/hello_world.zip"
}
