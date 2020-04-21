

provider "google" {
  credentials = file("../../dazzling-mantra-271319-bcb28c004aed.json")
  region  = "us-east1"
  zone    = "us-east1-a"
  project = "dazzling-mantra-271319"
}

resource "google_storage_bucket" "my_storage_bucket" {
  name          = "my-demo-storage-bucket"
  location      = "US"
}
