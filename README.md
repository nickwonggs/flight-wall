# Flight Wall

A single-file, zero-dependency live flight board. Open `flightwall.html` in any modern browser and it shows the aircraft currently flying near you, refreshed from the public OpenSky Network API. Cards animate in and out as flights enter and leave your radius, distances tick down between API refreshes via dead-reckoning, and a status bar tracks your daily request quota.

## Quick start

1. Double-click `flightwall.html`. It runs straight from `file://` — no server, no build, no npm.
2. Allow the location prompt so the app can centre the search box on you. If you deny it (or geolocation fails), it falls back to Singapore (1.3521, 103.8198) or the last cached location.
3. Watch the grid populate. The nearest flight is shown first; the title bar tracks its callsign.

## Settings (gear icon)

Click the gear icon in the top right to open the settings dialog:

- **Radius (km)** — search box around your location (default 50).
- **Max cards** — how many flights to show (default 8).
- **Poll interval — anonymous** — refresh seconds without an OpenSky account (default 30).
- **Poll interval — authenticated** — refresh seconds when credentials are set (default 20).
- **OpenSky username / password** — optional credentials for higher rate limits.

Settings persist in `localStorage`. Saving restarts polling immediately.

## OpenSky account (optional, recommended)

OpenSky's anonymous API is rate-limited (~400 requests/day). A free account raises this substantially (~4000/day) and lets you poll faster.

1. Sign up at <https://opensky-network.org/>.
2. Either enter your credentials in the gear-icon settings dialog, **or** edit the `OPENSKY_AUTH` constant near the top of `flightwall.html`:

   ```js
   const OPENSKY_AUTH = { user: "your_username", pass: "your_password" };
   ```

The constant takes precedence over the dialog values, so you can hard-code creds for a kiosk install and leave the dialog blank.

## Install as a PWA / desktop shortcut

In Microsoft Edge or Google Chrome:

1. Open `flightwall.html`.
2. Click the `...` menu → **Apps** → **Install this site as an app** (Edge) or **Cast, save and share** → **Install page as app** (Chrome).
3. The Flight Wall now lives in your Start menu like a native app.

## Kiosk shortcut

For a borderless, always-on board create a Windows shortcut to:

```
msedge.exe --app="file:///C:/Users/wongn/Desktop/repos/flight-wall/flightwall.html"
```

Works equally well with `chrome.exe`. Add `--start-fullscreen` if you want a true wall display.

## Troubleshooting

- **Empty grid** — no aircraft are inside your radius right now, or the OpenSky network sample is sparse. Increase the radius in settings, or wait for the next poll.
- **`Rate limited (429)`** — you have hit the OpenSky cap. The app automatically backs off (60s and up). Add credentials in the gear dialog to raise the cap, or wait until tomorrow (the daily counter resets at UTC midnight).
- **Stale cards** (dimmed, yellow last-contact line) — the aircraft has not reported a position for 60+ seconds. OpenSky receivers occasionally lose contact. The card disappears once it falls out of the API response.
- **Wrong location / no prompt** — clear the cached location with `localStorage.removeItem('fw.location')` in the dev console (F12) and reload.
- **Always shows Singapore** — geolocation was denied or unavailable. Allow the permission in the browser site settings, or set `fallbackLat` / `fallbackLon` in the `DEFAULT_CONFIG` block.

## Privacy

- Credentials and settings live in this browser's `localStorage` in plaintext on this device only.
- There is no backend. Requests go directly from your browser to `opensky-network.org`.
- Geolocation, when granted, is cached locally and only used to compute the search bounding box.

## v1 limitations

- No route data (origin / destination airports). OpenSky's free state-vectors endpoint does not provide it.
- No aircraft type / registration enrichment beyond the ICAO24 hex.
- No map view — the focus is a glanceable card wall.
- Airline name lookup is a best-effort prefix table (ICAO airline codes); unknown carriers fall back to the country of registry.
