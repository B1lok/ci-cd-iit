variable "credentials_file" {
  description = "Path to the GCP credentials JSON file"
  type        = string
}

variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "ssh_user" {
  description = "Username for SSH access"
  type        = string
}
