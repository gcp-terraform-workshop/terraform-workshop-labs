variable "project" {
  type = string
}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  type    = list(string)
  default = ["us-east1-b", "us-east1-c", "us-east1-d"]
}


variable "machine_type" {
  type = map(string)
  default = {
    "dev"  = "n1-standard-1"
    "prod" = ""
  }
}

variable "credential_location" {
  type = string
}

variable "name_count" {
  default = ["server-1", "server-2", "server-3"]
}

