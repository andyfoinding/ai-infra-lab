#!/usr/bin/env bash
set -euo pipefail

MODEL="Qwen/Qwen2.5-0.5B-Instruct"
IMAGE="vllm/vllm-openai:v0.11.0"
CONTAINER="vllm-inference"
MODEL_CACHE="/opt/ai-infra-lab/model-cache"

echo "Checking NVIDIA GPU..."
nvidia-smi

echo "Checking Docker..."
docker --version

echo "Checking NVIDIA Container Toolkit..."
docker info --format '{{json .Runtimes}}'

echo "Creating model cache..."
mkdir -p "$MODEL_CACHE"

echo "Creating shared monitoring network..."
docker network inspect ai-infra-network >/dev/null 2>&1 || \
  docker network create ai-infra-network

echo "Checking existing vLLM container..."

if docker container inspect "$CONTAINER" >/dev/null 2>&1; then
  echo "Removing existing vLLM container..."
  docker rm -f "$CONTAINER"
fi

echo "Starting vLLM..."

docker run -d \
  --name "$CONTAINER" \
  --restart no \
  --network ai-infra-network \
  --gpus all \
  --ipc=host \
  -p 127.0.0.1:8000:8000 \
  -v "$MODEL_CACHE:/root/.cache/huggingface" \
  "$IMAGE" \
  --model "$MODEL" \
  --host 0.0.0.0 \
  --port 8000

echo "vLLM container started."

echo "View logs with:"
echo "docker logs -f $CONTAINER"