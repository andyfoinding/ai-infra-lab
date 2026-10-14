resource "google_artifact_registry_repository" "ai_images" {
  location      = "us-east1"
  repository_id = "ai-infra-images"
  description   = "Docker images for AI infrastructure workloads"
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}