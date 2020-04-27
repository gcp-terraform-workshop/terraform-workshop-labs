

variable "project_id" {
  description = "The project ID to deploy resource into"
  default     = "terraform-containers" 
}

variable "subnetwork_project" {
  description = "The project ID where the desired subnetwork is provisioned"
  default     = "terraform-containers" 
}

variable "subnetwork" {
  description = "The name of the subnetwork to deploy instances into"
  default     = "default"
}

variable "instance_name" {
  description = "The desired name to assign to the deployed instance"
  default     = "disk-instance-vm-test"
}

variable "image" {
  description = "The Docker image to deploy to GCE instances"
 }

variable "image_port" {
  description = "The port the image exposes for HTTP requests"
}

variable "restart_policy" {
  description = "The desired Docker restart policy for the deployed image"
}

variable "machine_type" {
  description = "The GCP machine type to deploy"
}

variable "zone" {
  description = "The GCP zone to deploy instances into"
}

variable "additional_metadata" {
  type        = map(string)
  description = "Additional metadata to attach to the instance"
  default     = {}
}

variable "client_email" {
  description = "Service account email address"
  type        = string
  default     = ""
} 

variable "cos_image_name" {
  type   = string
  default = ""
}
