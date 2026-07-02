#!/bin/bash
# Double-click this file to stop the Flight Wall proxy on Mac.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIDFILE="$SCRIPT_DIR/.proxy.pid"

STOPPED=0

if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if kill "$PID" 2>/dev/null; then
        STOPPED=1
    fi
    rm -f "$PIDFILE"
fi

PIDS=$(lsof -ti :8765 2>/dev/null)
if [ -n "$PIDS" ]; then
    echo "$PIDS" | xargs kill -9 2>/dev/null
    STOPPED=1
fi

echo ""
if [ "$STOPPED" -eq 1 ]; then
    echo "  ✓ Flight Wall proxy stopped."
else
    echo "  No proxy was running."
fi
echo ""
sleep 1
