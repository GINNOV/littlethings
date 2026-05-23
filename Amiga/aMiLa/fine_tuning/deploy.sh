#!/bin/bash
set -e

# Configuration
PORT=1234
MODEL_DIR="fused_model"
LOG_FILE="server.log"

echo "=========================================================="
echo "Starting Antigravity Amiga Gemma-4 Serving Server"
echo "=========================================================="

if [ ! -d "$MODEL_DIR" ]; then
  echo "Error: $MODEL_DIR directory does not exist. Please run ./finetune.sh or fuse your adapters first."
  exit 1
fi

# Check if port 1234 is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
  echo "Port $PORT is already in use by another process!"
  echo "Checking if it is an active MLX-LM serving instance..."
  if curl -s "http://localhost:$PORT/v1/models" >/dev/null; then
    echo "Server is already running and responding cleanly on port $PORT."
    exit 0
  else
    echo "Warning: Another process is listening on port $PORT but not responding to /v1/models."
    echo "Please stop the other process and try again."
    exit 1
  fi
fi

echo "Launching MLX serving server in the background..."
echo "Model: $MODEL_DIR"
echo "Port: $PORT"
echo "Logs will be captured in: $LOG_FILE"

# Start the server in the background
# We run under uv run python -m mlx_lm.server
nohup uv run python -m mlx_lm.server --model "$MODEL_DIR" --port "$PORT" > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

echo "Server started with PID: $SERVER_PID"
echo "Waiting for the server to bind and respond to requests..."

# Poll the server endpoint up to 60 seconds
MAX_ATTEMPTS=30
ATTEMPT=0
SUCCESS=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
  if curl -s "http://localhost:$PORT/v1/models" >/dev/null; then
    SUCCESS=1
    break
  fi
  
  # Check if the process died
  if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo "Error: Server process has terminated unexpectedly. Printing tail of $LOG_FILE:"
    tail -n 20 "$LOG_FILE"
    exit 1
  fi
  
  sleep 2
  ATTEMPT=$((ATTEMPT + 1))
  echo -n "."
done

echo ""

if [ $SUCCESS -eq 1 ]; then
  echo "=========================================================="
  echo "Server is ONLINE and ready!"
  echo "OpenAI-compatible Endpoint: http://localhost:$PORT/v1"
  echo "Active Model information:"
  curl -s "http://localhost:$PORT/v1/models"
  echo ""
  echo "=========================================================="
else
  echo "Error: Server failed to respond on port $PORT within 60 seconds."
  echo "Checking logs:"
  tail -n 30 "$LOG_FILE"
  exit 1
fi
