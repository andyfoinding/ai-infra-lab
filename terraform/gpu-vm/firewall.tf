resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh-vllm"
  network = data.google_compute_network.ai_vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["vllm-gpu-lab"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}