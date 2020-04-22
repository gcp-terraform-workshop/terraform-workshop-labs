

provider "google" {
  credentials = file("~/booth-insight-sa.json")
  region  = "us-east1"
  zone    = "us-east1-a"
  project = "booth-test-55"
}


resource "google_storage_bucket" "my_storage_bucket" {
  name          = "booth-demo-storage-bucket"
  location      = "US"
}
