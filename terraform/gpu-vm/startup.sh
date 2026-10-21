#!/bin/bash
set -euo pipefail

logger "Configuring automatic shutdown for vLLM GPU lab"

systemd-run \
  --unit=vllm-lab-auto-shutdown \
  --on-active=3h \
  /usr/sbin/shutdown -h now

logger "Automatic shutdown scheduled for 3 hours"