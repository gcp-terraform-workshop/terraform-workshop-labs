variable "image" { default = "ubuntu-os-cloud/ubuntu-1910" }

variable "machine_name" { default = "lab"}
variable "zone" { default = "us-east1-c"}
variable "machine_count" { default = "1"}
variable "environment" {default = "production"}
variable "machine_type" {default =  "n1-standard-1" }
variable "machine_type_dev" {default = "n1-standard-4"}

variable "name_count" { default = ["server1", "server2", "server3"] }