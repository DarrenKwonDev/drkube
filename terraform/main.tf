terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.11.0"
    }
  }

  required_version = ">= 1.6"
}

# gcloud auth application-default login -> get creds

provider "google" {
  credentials = file("../credentials.json") 
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  credentials = file("../credentials.json") 
  project = var.project_id
  region  = var.region
}