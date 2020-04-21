variable "project" {
  type = string
 }

variable "region" {
  default = "us-east1"
}

variable "zone" {
 type = list(string)
  default = ["us-east1-b","us-east1-c","us-east1-d"]
  } 

variable "tags" {
 default = "dev"
}

 output "test" {
 value = var.zone[1]
}
