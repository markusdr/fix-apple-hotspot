# 🔗 macOS Hotspot Fix Script

A robust and user-friendly Bash script to reliably connect your Mac to an iPhone Personal Hotspot — even when macOS fails to detect or join it automatically.

### ✨ Why This Script?

Connecting to an iPhone Personal Hotspot on macOS has long been unreliable. Many users have reported persistent issues, such as those described in this [Reddit thread](https://www.reddit.com/r/iphone/comments/138ec2r/apple_iphone_hotspot_problem).

After struggling with this problem myself, I discovered that restarting the network interface and disabling IPv6 consistently resolved the issue. This script automates that process — making hotspot connections **predictable**, **repeatable**, and far more **reliable**.


## ✅ Features

- Enables Wi-Fi if it's off
- Disables IPv6 for improved hotspot stability
- Connects to a user-specified or environment-configured hotspot
- Displays a live connection timer
- Re-enables IPv6 on script exit
- Graceful shutdown with `Ctrl+C`

## 🔧 Requirements

- macOS (tested on Monterey and later)
- Admin privileges (for interface restart and IPv6 config)

## 🚀 Usage

Before running the script, **you must make your iPhone’s Personal Hotspot discoverable**.

🔓 **Important:** Even if *"Allow Others to Join"* is enabled, iPhones often do not advertise the hotspot over Wi-Fi unless explicitly made discoverable. You can do this in two ways:

- **Settings method:**  
  Open **Settings → Personal Hotspot** and keep the screen open. This reliably makes the hotspot visible to nearby devices.
  
- **Control Center method:**  
  Swipe down from the top right of the screen to open **Control Center**, long-press the tile with Wi-Fi/Bluetooth, and tap the **Personal Hotspot icon** to turn it on. This also makes the hotspot discoverable for a short time.

> 💡 Tip: If the script fails to connect immediately, double-check that your hotspot is visible using one of the methods above.

Once your hotspot is discoverable on your iPhone, run the script using either method below:

### Envrionment Variables
Define SSID and password through environment variables.

```bash
export HOTSPOT_NAME='Your Hotspot SSID'
export HOTSPOT_PASSWORD='YourHotSpotPassword'
./hotspot_connect.sh
```
You can add these `export` commands to your `~/.bash_profile` script to define them permanently.

### Command Line Argument
Or, provide the SSID directly on the command line:

```bash
./hotspot_connect.sh --ssid "Your Hotspot SSID"
```
The script will ask for your SSID password in order to connect.

### Help

```bash
./hotspot_connect.sh --help
```

## 📱 What's My iPhone hotspot SSID name?

By default, your iPhone’s hotspot SSID is the same as the device name, typically following this format:
"\<YourName\>’s iPhone", e.g., `John’s iPhone`.

You can find your current hotspot name by:

- **Opening the Wi-Fi menu** from the top-right menu bar on your Mac — the hotspot name will appear there when your iPhone is discoverable.
- Or by going to **Settings → General → About → Name** on your iPhone to view or change it.

> ⚠️ **Note:** macOS and command-line tools may misinterpret certain characters (like the curly apostrophe `’`).  
> For best results when using this script, consider renaming your iPhone to something simpler, like `JohnsPhone` or `MyiPhone` — avoiding spaces, quotes, and punctuation.
 

## ⚙️ What The Script Does

1. Detects your Mac’s Wi-Fi interface
2. Turns on Wi-Fi if disabled
3. Restarts the interface, flushes DNS, renews DHCP
4. Disables IPv6 (this is key for many hotspot issues)
5. Attempts to connect to the specified hotspot
6. Retries if the hotspot is not yet discoverable
7. Shows a live timer indicating how long you've been connected
8. On `Ctrl+C`, re-enables IPv6 and exits cleanly

## 🛡 Security Note

The script:

- Never stores your hotspot password
- Uses secure input (`read -rsp`) if you don’t want to export your password in your shell

## 🧹 Cleanup on Exit

The script traps `SIGINT` and `SIGTERM` to:
- Stop the connection timer
- Re-enable IPv6
- Exit cleanly with a success message

## 📎 Example Output

```
🌐 Network Interface Detected: en0
⚡ Wi-Fi is OFF. Turning it ON...
🔄 Restarting network interface en0...
🔐 Admin privileges are active (no password will be prompted).
🧹 Flushing DNS cache...
🔄 Renewing DHCP lease...
🛑 Disabling IPv6 for better hotspot stability...
📡 Connecting to hotspot: JohnsPhone...
⏳ Waiting for Wi-Fi connection to stabilize...
✅ Detected WiFi connection. IP Address: 175.32.20.3
⏱ Connected for: 00:03:45
```

## 📂 License

MIT License — feel free to use, modify, and share.

