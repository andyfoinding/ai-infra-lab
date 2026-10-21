terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = "ai-infra-lab-2026"
  region  = "us-east1"
  zone    = "us-east1-c"
}