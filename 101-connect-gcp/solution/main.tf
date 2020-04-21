// terraform {
//   required_version = ">= 0.12.6"
//   required_providers {
//     google = ">= 3.00"
//   }
// }

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

// resource "google_storage_bucket" "count" {
//   name     = "my-demo-storage-bucket-${count.index}"
//   location = "US"
//   count    = 2
// }