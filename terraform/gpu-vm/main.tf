data "google_compute_network" "ai_vpc" {
  name = "ai-infra-vpc"
}

data "google_compute_subnetwork" "ai_subnet" {
  name   = "ai-infra-subnet"
  region = "us-east1"
}
resource "google_compute_instance" "vllm_gpu" {
  name         = "vllm-gpu-lab"
  machine_type = "g2-standard-4"
  zone         = "us-east1-c"

  tags = ["vllm-gpu-lab"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 100
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.ai_subnet.self_link

    # Temporary external IP for outbound internet access
    access_config {}
  }

  guest_accelerator {
    type  = "nvidia-l4"
    count = 1
  }

  scheduling {
    on_host_maintenance = "TERMINATE"
    automatic_restart   = false
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  metadata = {
    enable-oslogin = "TRUE"
  }
  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true

  }
}