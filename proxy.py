"""
Flight Wall local proxy — fixes CORS for PlaneSpotters photos and adds
authentication for OpenSky Network API requests.

Usage:
    python proxy.py [username] [password]

If no arguments given, reads credentials from proxy-config.txt (one per line):
    Line 1: username
    Line 2: password

Credentials are optional — the proxy starts in anonymous mode if none are
provided. Photos will work either way; authenticated OpenSky gives higher
rate limits (~4 000 req/day vs 400).

Then set Proxy URL to http://localhost:8888 in Flight Wall settings.
"""
import sys
import os
import base64
import urllib.request
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 8888
_UA = "Mozilla/5.0 (compatible; FlightWall/1.0)"

USER = sys.argv[1] if len(sys.argv) > 2 else ""
PASS = sys.argv[2] if len(sys.argv) > 2 else ""

# Fall back to proxy-config.txt if no CLI args
if not USER or not PASS:
    config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "proxy-config.txt")
    if os.path.exists(config_path):
        with open(config_path, encoding="utf-8") as f:
            lines = [l.strip() for l in f.read().splitlines()]
        USER = lines[0] if len(lines) > 0 else ""
        PASS = lines[1] if len(lines) > 1 else ""

TOKEN = base64.b64encode(f"{USER}:{PASS}".encode()).decode() if USER and PASS else ""
if USER and PASS:
    print(f"[FlightWall Proxy] Starting on http://localhost:{PORT} (user={USER})")
else:
    print(f"[FlightWall Proxy] Starting on http://localhost:{PORT} (anonymous — photos only)")
    print("[FlightWall Proxy] Add OpenSky credentials to proxy-config.txt for higher rate limits")
print("[FlightWall Proxy] Running — keep this process alive or use start-proxy.command")


class Handler(BaseHTTPRequestHandler):
    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "*")

    def do_OPTIONS(self):
        self.send_response(200)
        self._cors()
        self.end_headers()

    def do_GET(self):
        if self.path.startswith("/planespotters/"):
            target = "https://api.planespotters.net" + self.path[len("/planespotters"):]
            req = urllib.request.Request(target, headers={
                "User-Agent": _UA,
                "Referer": "https://www.planespotters.net/",
                "Accept": "application/json",
            })
        else:
            target = "https://opensky-network.org" + self.path
            headers = {"User-Agent": _UA}
            if TOKEN:
                headers["Authorization"] = f"Basic {TOKEN}"
            req = urllib.request.Request(target, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                data = resp.read()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self._cors()
            self.end_headers()
            self.wfile.write(data)
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self._cors()
            self.end_headers()
        except Exception as e:
            self.send_response(502)
            self._cors()
            self.end_headers()
            self.wfile.write(str(e).encode())

    def log_message(self, fmt, *args):
        print(f"[proxy] {args[0]} {args[1]}")


HTTPServer(("localhost", PORT), Handler).serve_forever()
