#!/usr/bin/env bash
set -euo pipefail

API_URL="${API_URL:-http://127.0.0.1:8000}"
MODEL="Qwen/Qwen2.5-0.5B-Instruct"

echo "======================================"
echo "AI Infrastructure Lab - vLLM API Test"
echo "======================================"

echo ""
echo "[1/3] Waiting for vLLM to become healthy..."

healthy=false

for i in {1..60}; do
    if curl -fsS --max-time 5 "$API_URL/health" >/dev/null; then
        healthy=true
        break
    fi

    echo "Waiting for vLLM... ($i/60)"
    sleep 5
done

if [[ "$healthy" != true ]]; then
    echo "ERROR: vLLM did not become healthy."
    exit 1
fi

echo "vLLM is healthy."

echo ""
echo "[2/3] Checking available models..."

curl -fsS "$API_URL/v1/models"

echo ""
echo ""
echo "[3/3] Testing inference..."

curl -fsS \
    -X POST "$API_URL/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
            {
                \"role\": \"user\",
                \"content\": \"Explain what a GPU does in one sentence.\"
            }
        ],
        \"max_tokens\": 100
    }"

echo ""
echo ""
echo "======================================"
echo "vLLM API test completed successfully!"
echo "======================================"