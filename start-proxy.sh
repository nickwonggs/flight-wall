#!/bin/bash
# Start Flight Wall proxy in background (macOS)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIDFILE="$SCRIPT_DIR/.proxy.pid"
LOGFILE="$SCRIPT_DIR/proxy.log"

# Kill existing instance
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    kill "$OLD_PID" 2>/dev/null
    rm -f "$PIDFILE"
fi

# Also kill anything on port 8765
lsof -ti :8765 | xargs kill -9 2>/dev/null

# Start proxy
nohup python3 "$SCRIPT_DIR/proxy.py" >> "$LOGFILE" 2>&1 &
PROXY_PID=$!
echo $PROXY_PID > "$PIDFILE"

sleep 0.8
if kill -0 "$PROXY_PID" 2>/dev/null; then
    echo "Flight Wall proxy started (PID $PROXY_PID)"
    echo "Proxy URL: http://localhost:8765"
    echo "Log: $LOGFILE"
else
    echo "[ERROR] Proxy failed to start. Check $LOGFILE"
    exit 1
fi
