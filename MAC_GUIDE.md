# Flight Wall on macOS — Complete Beginner's Guide

This guide is written for someone who has never opened Terminal before. Follow the steps in order. Most people only need **Part 1** — no Terminal required at all.

---

## Part 1 — Basic setup (no Terminal required)

### Step 1 — Download the files

1. Go to the GitHub repository page in your browser.
2. Click the green **Code** button near the top right.
3. Click **Download ZIP**.
4. Your Mac will save a file called `flight-wall-main.zip` to your **Downloads** folder.
5. Double-click that ZIP file to unzip it. A folder called `flight-wall-main` will appear next to it.

### Step 2 — Open the Flight Wall

1. Open the `flight-wall-main` folder.
2. Find the file named **`flightwall.html`**.
3. Double-click it. It will open in your default web browser (Safari, Chrome, or Firefox).

> **Nothing installed yet and it already works.** The app is a single self-contained file — no server, no internet connection required beyond fetching live flight data.

### Step 3 — Allow location access

When the page loads, your browser will ask:
> *"[Browser] wants to know your location"*

- Click **Allow** so the app centres the map on where you are.
- If you click **Don't Allow**, the app falls back to a default location (Singapore). You can still use it — flights near Singapore will show up instead of flights near you.

### Step 4 — Watch the flights appear

The grid will fill with flight cards within about 30 seconds. The nearest flight is shown first. Cards animate in and out as aircraft enter or leave your area.

That's it for basic use. The rest of this guide is optional.

---

## Part 2 — Free OpenSky account (recommended, no Terminal required)

The app fetches flight data from the OpenSky Network. Without an account you get roughly **400 requests per day** and the data refreshes every 30 seconds. A **free account** raises this to ~4 000 requests/day and lets the app refresh every 20 seconds.

### Step 1 — Create a free account

1. Go to **https://opensky-network.org/**
2. Click **Sign Up** and fill in the form. Verify your email.

### Step 2 — Enter your credentials in the app

1. Open `flightwall.html` in your browser (if it isn't already open).
2. Click the **gear icon** (⚙) in the top-right corner.
3. Scroll down to the **OpenSky username** and **OpenSky password** fields.
4. Type in the username and password you just created.
5. Click **Save**.

The app will restart polling immediately using your account.

---

## Part 3 — Proxy setup for authenticated route data (requires Terminal once)

Route origin/destination information and a higher API rate limit require a local proxy. This section uses Terminal — but only for a few copy-paste commands.

### Step 1 — Open Terminal

1. Press **Command (⌘) + Space** to open Spotlight Search.
2. Type `Terminal` and press **Return**.
3. A white (or black) window with a blinking cursor will appear. This is Terminal.

> Terminal lets you type commands directly to your Mac. You will only need it for a few minutes.

### Step 2 — Navigate to the Flight Wall folder

You need to tell Terminal where the Flight Wall files are. The easiest way:

1. In Terminal, type `cd ` (the word "cd" followed by a single space — **do not press Return yet**).
2. Open a Finder window and find the `flight-wall-main` folder.
3. Drag the `flight-wall-main` folder directly onto the Terminal window. The folder path will be pasted automatically.
4. Now press **Return**.

You should see the prompt change to show the folder name. For example:
```
user@MacBook flight-wall-main %
```

### Step 3 — Check that Python is installed

Type this command and press **Return**:
```
python3 --version
```

- If you see something like `Python 3.x.x` you are ready. Skip to Step 4.
- If you see `command not found`, you need to install Python:
  1. Go to **https://www.python.org/downloads/**
  2. Click **Download Python 3.x.x** (the big yellow button).
  3. Open the downloaded `.pkg` file and follow the installer.
  4. Come back to Terminal and repeat this step to confirm it worked.

### Step 4 — Run the setup script

Type this command exactly and press **Return**:
```
bash setup.sh
```

The script will ask you two questions:

**Question 1 — OpenSky credentials**
```
OpenSky username (leave blank to skip):
```
Type your OpenSky username and press **Return**. Then type your password (it will be invisible as you type — that is normal) and press **Return**.

**Question 2 — Auto-start on login**
```
Auto-start proxy on Mac login? (y/n):
```
- Type `y` and press **Return** if you want the proxy to start automatically every time you turn on your Mac (recommended for a permanent flight wall display).
- Type `n` if you prefer to start it manually.

You will see `Setup complete!` when it finishes. You can now close Terminal.

### Step 5 — Start the proxy

In the `flight-wall-main` folder, find the file **`start-proxy.command`**.

**First time only — Mac security prompt:**
1. Right-click (or Control-click) `start-proxy.command`.
2. Click **Open**.
3. A dialog will say *"macOS cannot verify the developer…"* — click **Open** again.

From now on you can just double-click it.

A Terminal window will open briefly and show:
```
  ✓ Flight Wall proxy is running.

  In Flight Wall settings (gear icon),
  set Proxy URL to:  http://localhost:8888
```
You can close that window — the proxy keeps running in the background.

### Step 6 — Tell the app to use the proxy

1. Open `flightwall.html` in your browser (or reload it if already open).
2. Click the **gear icon** (⚙) in the top-right corner.
3. Find the **Proxy URL** field.
4. Type: `http://localhost:8888`
5. Click **Save**.

Route origin/destination data will now appear on flight cards.

### Step 7 — Stop the proxy when you're done (optional)

Double-click **`stop-proxy.command`** in the flight-wall folder.

> Same first-time security step as above: right-click → Open → Open.

---

## Part 4 — Troubleshooting

| Problem | What to do |
|---|---|
| **Grid is empty** | No flights are in your radius right now. Open ⚙ Settings and increase the **Radius (km)** value (try 100 or 200). Wait for the next refresh. |
| **"Rate limited (429)"** | You've hit OpenSky's daily request cap. Add credentials in the gear icon settings, or wait until midnight UTC for the counter to reset. |
| **Cards are dimmed / yellow** | The aircraft hasn't reported a position for 60+ seconds. It will disappear automatically on the next API refresh. |
| **Always shows Singapore** | Location access was denied. In your browser, click the padlock icon next to the address bar, find **Location**, and change it to **Allow**. Then reload the page. |
| **`start-proxy.command` won't open** | Right-click it → Open → Open (the Mac security bypass described in Part 3, Step 5). |
| **`bash setup.sh` says "Permission denied"** | Type `chmod +x setup.sh` and press Return, then run `bash setup.sh` again. |
| **Proxy shows "failed to start"** | Open the file `proxy.log` in the flight-wall folder with TextEdit to see the error message. Most commonly Python is missing — see Part 3, Step 3. |

---

## Quick reference

| Task | How |
|---|---|
| Open the app | Double-click `flightwall.html` |
| Change radius / max cards | Gear icon ⚙ → adjust → Save |
| Start proxy | Double-click `start-proxy.command` |
| Stop proxy | Double-click `stop-proxy.command` |
| Check proxy is running | Open a browser tab and go to `http://localhost:8888` — you should see a short JSON response |
