#!/bin/bash
# Flight Wall setup for macOS

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_LABEL="com.flightwall.proxy"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"

echo ""
echo " =============================="
echo "   Flight Wall - Setup (Mac)"
echo " =============================="
echo ""

# Check Python
if ! command -v python3 &>/dev/null; then
    echo "[ERROR] python3 not found. Install from https://python.org or via Homebrew:"
    echo "        brew install python3"
    exit 1
fi
echo "[OK] $(python3 --version)"

# Fix execute permissions on .command files (lost when unzipped on macOS)
chmod +x "$SCRIPT_DIR/start-proxy.command" "$SCRIPT_DIR/stop-proxy.command" 2>/dev/null
echo "[OK] Execute permissions set on .command files"

# Collect credentials
echo ""
echo "Enter your OpenSky Network credentials."
echo "(Free account at https://opensky-network.org — optional but recommended)"
echo ""
read -rp "OpenSky username (leave blank to skip): " OSUSER
if [ -z "$OSUSER" ]; then
    echo "Skipping credentials — anonymous mode only."
else
    read -rsp "OpenSky password: " OSPASS
    echo ""
    printf '%s\n%s\n' "$OSUSER" "$OSPASS" > "$SCRIPT_DIR/proxy-config.txt"
    echo "[OK] Saved credentials to proxy-config.txt"
fi

# Auto-start via launchd
echo ""
read -rp "Auto-start proxy on Mac login? (y/n): " STARTUP
if [[ "$STARTUP" =~ ^[Yy]$ ]]; then
    cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(command -v python3)</string>
        <string>$SCRIPT_DIR/proxy.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>$SCRIPT_DIR/proxy.log</string>
    <key>StandardErrorPath</key>
    <string>$SCRIPT_DIR/proxy.log</string>
</dict>
</plist>
EOF
    launchctl load "$PLIST_PATH" 2>/dev/null
    echo "[OK] Proxy will auto-start at login (launchd)."
fi

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open flightwall.html in your browser"
echo "  2. Click the gear icon (top-right)"
if [ -n "$OSUSER" ]; then
    echo "  3. Set Proxy URL to: http://localhost:8765"
    echo "  4. Run ./start-proxy.sh to start the proxy now"
else
    echo "  3. Enter credentials when you have an OpenSky account"
fi
echo ""
