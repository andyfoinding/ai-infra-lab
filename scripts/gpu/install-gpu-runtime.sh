#!/usr/bin/env bash
set -euo pipefail

# ==================================================
# AI Infrastructure Lab - GPU Runtime Installation
# OS: Ubuntu 22.04
# GPU: NVIDIA L4
# ==================================================

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run this script with sudo."
    exit 1
fi

source /etc/os-release

if [[ "$ID" != "ubuntu" || "$VERSION_ID" != "22.04" ]]; then
    echo "ERROR: This script requires Ubuntu 22.04."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "======================================"
echo "Step 1: Installing dependencies"
echo "======================================"

apt-get update

apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    python3 \
    pciutils

echo "======================================"
echo "Step 2: Installing NVIDIA GPU driver"
echo "======================================"

# Use Google's official Compute Engine GPU installer.
# This supports NVIDIA GPUs on GCE.

if ! command -v nvidia-smi >/dev/null 2>&1; then

    mkdir -p /opt/google/cuda-installer
    cd /opt/google/cuda-installer

    curl -fSsL \
        -o cuda_installer.pyz \
        https://storage.googleapis.com/compute-gpu-installation-us/installer/latest/cuda_installer.pyz

    python3 cuda_installer.pyz install_driver

else
    echo "NVIDIA driver already installed."
fi

echo "======================================"
echo "Step 3: Installing Docker Engine"
echo "======================================"

if ! command -v docker >/dev/null 2>&1; then

    apt-get install -y docker.io

else
    echo "Docker already installed."
fi

systemctl enable --now docker

echo "======================================"
echo "Step 4: Installing NVIDIA Container Toolkit"
echo "======================================"

curl -fsSL \
    https://nvidia.github.io/libnvidia-container/gpgkey \
    | gpg --dearmor \
        -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -fsSL \
    https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    > /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update

apt-get install -y nvidia-container-toolkit

echo "======================================"
echo "Step 5: Configuring NVIDIA Docker Runtime"
echo "======================================"

nvidia-ctk runtime configure --runtime=docker

systemctl restart docker

echo "======================================"
echo "Step 6: Verifying Installation"
echo "======================================"

docker --version

nvidia-ctk --version

echo "Checking NVIDIA GPU driver..."

if nvidia-smi; then
    echo "NVIDIA driver is operational."
else
    echo "WARNING: NVIDIA driver may require a reboot."
    echo "Reboot the VM, then run nvidia-smi again."
fi

echo "======================================"
echo "GPU Runtime Installation Complete"
echo "======================================"

echo "Next steps:"
echo "1. Verify GPU: nvidia-smi"
echo "2. Verify Docker: sudo docker info"
echo "3. Deploy vLLM using deploy-vllm.sh"