"""
Flight Wall local proxy — bypasses OpenSky CORS restrictions for authenticated requests.

Usage:
    python proxy.py <opensky_username> <opensky_password>

Then in Flight Wall settings, set Proxy URL to: http://localhost:8888
"""
import sys
import base64
import urllib.request
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 8888
USER = sys.argv[1] if len(sys.argv) > 2 else ""
PASS = sys.argv[2] if len(sys.argv) > 2 else ""

if not USER or not PASS:
    print("Usage: python proxy.py <username> <password>")
    sys.exit(1)

TOKEN = base64.b64encode(f"{USER}:{PASS}".encode()).decode()
print(f"[FlightWall Proxy] Starting on http://localhost:{PORT} (auth: user={USER})")


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
        target = "https://opensky-network.org" + self.path
        req = urllib.request.Request(target, headers={"Authorization": f"Basic {TOKEN}"})
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
