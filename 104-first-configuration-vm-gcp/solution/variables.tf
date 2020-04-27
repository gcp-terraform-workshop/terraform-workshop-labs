
variable "project_id" {
  description = "The GCP project id"
  type        = string
}

variable "region" {
  default     = "us-east1"
  description = "GCP region"
  type        = string
}

variable "svc_acct_email" {
  default     = ""
  description = "email account for VM service account"
  type        = string
}