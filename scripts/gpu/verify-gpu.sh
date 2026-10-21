#!/usr/bin/env bash
set -euo pipefail

echo "===================================="
echo "AI Infrastructure Lab - GPU Check"
echo "===================================="

echo ""
echo "[1/3] Checking NVIDIA GPU..."

nvidia-smi

echo ""
echo "[2/3] Checking Docker..."

docker --version

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon is not accessible."
    echo "Try running this script with sudo."
    exit 1
fi

echo ""
echo "[3/3] Testing GPU access from Docker..."

docker run --rm \
    --gpus all \
    ubuntu:22.04 \
    nvidia-smi

echo ""
echo "===================================="
echo "GPU verification successful!"
echo "===================================="