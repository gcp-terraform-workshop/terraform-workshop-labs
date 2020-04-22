
terraform {
  backend "gcs" {
    credentials = "../../dazzling-mantra-271319-bcb28c004aed.json"
    bucket  = "my-demo-storage-bucket"
    prefix  = "terraform/state"
  
  }
}

provider "google" {
  credentials = file("../../dazzling-mantra-271319-bcb28c004aed.json")
  region  = "us-east1"
  zone    = "us-east1-a"
  project = "dazzling-mantra-271319"
  
}

