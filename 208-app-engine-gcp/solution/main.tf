provider "google" {
  credentials = file("terraform.json")

}

resource "google_app_engine_standard_app_version" "myapp_v1" {
  version_id = "v1"
  service    = "myapp"
  runtime    = "nodejs10"
  project    = "My Project 44548"

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

resource "google_app_engine_standard_app_version" "myapp_v2" {
  version_id = "v2"
  service    = "myapp"
  runtime    = "nodejs10"
  project    = "My Project 44548"

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

  noop_on_destroy = true
}

resource "google_storage_bucket" "bucket" {
  name    = "insight20"
  project = "silver-rain-275618"

}

resource "google_storage_bucket_object" "object" {
  name   ="hello_world.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./file/hello_world.zip"
}


