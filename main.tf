variable "gcs_bucket_name" {
  description = "Google Cloud Storage bucket for Terraform state"
}

variable "google_project" {
  description = "Google Cloud Project ID"
}

variable "google_region" {
  description = "Google Cloud Region"
}

variable "google_credentials_file" {
  description = "Path to Google Cloud credentials file"
  default     = "/tmp/gcp-key.json" # Path to where the file will be created
  sensitive   = true
}

terraform {
  backend "gcs" {}
}

provider "google" {
  project     = var.google_project
  region      = var.google_region
  credentials = file(var.google_credentials_file)
}

resource "google_cloud_run_v2_service" "test-service" {
  name                = "test-workflow-service-unseald"
  location            = var.google_region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "nginx:latest"
      ports {
        name           = "http1"
        container_port = 80
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "allow_unauthenticated" {
  service  = google_cloud_run_v2_service.test-service.name
  location = google_cloud_run_v2_service.test-service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
