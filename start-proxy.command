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

# Warn if no credentials, but allow proxy to start (photos work without them)
if [ ! -f "$SCRIPT_DIR/proxy-config.txt" ]; then
    echo ""
    echo "  No proxy-config.txt found — starting in anonymous mode."
    echo "  Aircraft photos will work. For higher OpenSky rate limits,"
    echo "  run setup.sh to add your OpenSky credentials."
    echo ""
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
    echo "  This enables aircraft photos and (with credentials) authenticated"
    echo "  OpenSky access. You can close this window — proxy runs in background."
    echo ""
else
    echo ""
    echo "  ✗ Proxy failed to start. Check proxy.log for details."
    echo ""
    read -rp "Press Enter to close..."
fi
