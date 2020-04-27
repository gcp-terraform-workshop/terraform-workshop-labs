
# variable "path" {default = "/home/udemy/terraform/credentials"}

provider "google" {
  project = "mimetic-pursuit-271713"
  region  = "us-east1-c"
  # credentials = "${file("${var.path}/secrets.json")}"
}