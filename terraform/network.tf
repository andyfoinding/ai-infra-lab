resource "google_compute_network" "ai_vpc" {
  name                    = "ai-infra-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ai_subnet" {
  name          = "ai-infra-subnet"
  region        = "us-east1"
  network       = google_compute_network.ai_vpc.id
  ip_cidr_range = "10.10.0.0/24"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.30.0.0/20"
  }
}