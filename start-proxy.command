#!/bin/bash
# Double-click this file to start the Flight Wall proxy on Mac.
# Terminal will open, start the proxy, then you can close this window.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIDFILE="$SCRIPT_DIR/.proxy.pid"
LOGFILE="$SCRIPT_DIR/proxy.log"

# Kill any existing instance
if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
fi
lsof -ti :8888 | xargs kill -9 2>/dev/null

# Check proxy-config.txt
if [ ! -f "$SCRIPT_DIR/proxy-config.txt" ]; then
    echo ""
    echo "  proxy-config.txt not found."
    echo "  Run setup.sh first, or create proxy-config.txt with:"
    echo "    Line 1: your OpenSky username"
    echo "    Line 2: your OpenSky password"
    echo ""
    read -rp "Press Enter to close..."
    exit 1
fi

# Start proxy in background
nohup python3 "$SCRIPT_DIR/proxy.py" >> "$LOGFILE" 2>&1 &
echo $! > "$PIDFILE"
sleep 1

if kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo ""
    echo "  ✓ Flight Wall proxy is running."
    echo ""
    echo "  In Flight Wall settings (gear icon),"
    echo "  set Proxy URL to:  http://localhost:8888"
    echo ""
    echo "  You can close this window — proxy keeps running in background."
    echo ""
else
    echo ""
    echo "  ✗ Proxy failed to start. Check proxy.log for details."
    echo ""
    read -rp "Press Enter to close..."
fi
