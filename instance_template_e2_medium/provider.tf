terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
#      version = "~> 7.0.1"
    }
  }
}

provider "google" {
  project     = "carbon-gecko-472110-u1"
  region      = "europe-west9"
  zone        = "europe-west9-b"
  credentials = file(var.path)
}