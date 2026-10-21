#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo " AI Infrastructure - GPU Monitoring"
echo "======================================"

# Find the repository root regardless of where the script is executed.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMPOSE_FILE="$REPO_ROOT/monitoring/gpu-vm/docker-compose.yml"

echo "[1/5] Checking prerequisites..."

command -v docker >/dev/null || {
  echo "ERROR: Docker is not installed."
  exit 1
}

docker compose version >/dev/null || {
  echo "ERROR: Docker Compose plugin is unavailable."
  exit 1
}

docker info >/dev/null || {
  echo "ERROR: Cannot access Docker daemon."
  exit 1
}

command -v nvidia-smi >/dev/null || {
  echo "ERROR: NVIDIA drivers are unavailable."
  exit 1
}

nvidia-smi

echo "[2/5] Checking shared Docker network..."

if ! docker network inspect ai-infra-network >/dev/null 2>&1; then
  docker network create ai-infra-network
fi

echo "[3/5] Checking Grafana password..."

if [[ -z "${GRAFANA_ADMIN_PASSWORD:-}" ]]; then
  echo "ERROR: Set GRAFANA_ADMIN_PASSWORD before deployment."
  exit 1
fi

echo "[4/5] Starting monitoring containers..."

docker compose -f "$COMPOSE_FILE" up -d

echo "[5/5] Checking container status..."

docker compose -f "$COMPOSE_FILE" ps

echo
echo "Checking Prometheus..."

for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:9090/-/ready >/dev/null; then
    echo "Prometheus is ready."
    break
  fi

  if [[ "$attempt" -eq 30 ]]; then
    echo "ERROR: Prometheus did not become ready."
    exit 1
  fi

  sleep 2
done

echo "Checking Grafana..."

for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:3000/api/health >/dev/null; then
    echo "Grafana is responding."
    break
  fi

  if [[ "$attempt" -eq 30 ]]; then
    echo "ERROR: Grafana did not become ready."
    exit 1
  fi

  sleep 2
done

echo
echo "Checking NVIDIA DCGM Exporter..."

if curl -fsS http://127.0.0.1:9400/metrics | grep '^DCGM_FI_' >/dev/null; then
  echo "NVIDIA GPU metrics are available."
else
  echo "WARNING: NVIDIA GPU metrics are not available yet."
fi

echo
echo "Checking Prometheus scrape targets..."

curl -fsS \
  "http://127.0.0.1:9090/api/v1/targets?state=active" \
  | python3 -c '
import json
import sys

data = json.load(sys.stdin)

for target in data.get("data", {}).get("activeTargets", []):
    labels = target.get("labels", {})
    job = labels.get("job", "unknown")
    health = target.get("health", "unknown")
    print(f"  {job}: {health}")
'

echo
echo "======================================"
echo " Monitoring deployment completed"
echo "======================================"

echo "Prometheus: http://127.0.0.1:9090"
echo "Grafana:    http://127.0.0.1:3000"