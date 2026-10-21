#!/usr/bin/env bash
set -euo pipefail

MODEL="Qwen/Qwen2.5-0.5B-Instruct"
IMAGE="vllm/vllm-openai:v0.11.0"
CONTAINER="vllm-inference"

echo "Checking NVIDIA GPU..."

nvidia-smi

echo "Checking Docker..."

docker --version

echo "Checking NVIDIA Container Toolkit..."

docker info --format '{{json .Runtimes}}'

echo "Creating model cache..."

mkdir -p "$HOME/vllm-model-cache"

echo "Starting vLLM..."

docker run -d \
  --name "$CONTAINER" \
  --restart no \
  --gpus all \
  --ipc=host \
  -p 127.0.0.1:8000:8000 \
  -v "$HOME/vllm-model-cache:/root/.cache/huggingface" \
  "$IMAGE" \
  --model "$MODEL" \
  --host 0.0.0.0 \
  --port 8000

echo "vLLM container started."

echo "View logs with:"
echo "docker logs -f $CONTAINER"