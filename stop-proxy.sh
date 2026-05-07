#!/bin/bash
# Stop Flight Wall proxy (macOS)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIDFILE="$SCRIPT_DIR/.proxy.pid"

STOPPED=0

if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if kill "$PID" 2>/dev/null; then
        echo "Stopped proxy (PID $PID)"
        STOPPED=1
    fi
    rm -f "$PIDFILE"
fi

# Also sweep port 8888 in case pidfile is stale
PIDS=$(lsof -ti :8888 2>/dev/null)
if [ -n "$PIDS" ]; then
    echo "$PIDS" | xargs kill -9 2>/dev/null
    STOPPED=1
fi

if [ "$STOPPED" -eq 1 ]; then
    echo "Flight Wall proxy stopped."
else
    echo "No proxy running."
fi
