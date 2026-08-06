#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

PORT="${PORT:-1234}"
LOG_FILE="${LOG_FILE:-server.log}"

echo "=========================================================="
echo "Amiga Playground MLX — amiga-playground-asm"
echo "=========================================================="

if [[ ! -d runtime/base ]] || [[ ! -f runtime/adapter/adapters.safetensors ]]; then
  echo "Missing runtime/. Run: ./download_model.sh"
  exit 1
fi

if lsof -Pi :"$PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  if curl -s "http://localhost:$PORT/v1/models" >/dev/null; then
    echo "Already up on port $PORT"
    exit 0
  fi
  echo "Port $PORT busy by non-MLX process"
  exit 1
fi

nohup uv run python serve_playground.py --port "$PORT" >"$LOG_FILE" 2>&1 &
PID=$!
echo "PID $PID — waiting..."

for i in $(seq 1 30); do
  if curl -s "http://localhost:$PORT/v1/models" >/dev/null 2>&1; then
    echo "ONLINE http://localhost:$PORT/v1  model id: amiga-playground-asm"
    curl -s "http://localhost:$PORT/v1/models" | head -c 500
    echo
    exit 0
  fi
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "Server died:"; tail -30 "$LOG_FILE"; exit 1
  fi
  sleep 2
done
echo "Timeout:"; tail -30 "$LOG_FILE"; exit 1
