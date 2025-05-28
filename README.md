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

### Option 1: Using environment variables

```bash
export HOTSPOT_NAME="YourHotspotSSID"
export HOTSPOT_PASSWORD="YourHotspotPassword"
./hotspot_connect.sh
```

### Option 2: Prompting for password

```bash
./hotspot_connect.sh --ssid YourHotspotSSID
# You'll be prompted for the password securely
```

### Help

```bash
./hotspot_connect.sh --help
```

## ⚙️ What It Does

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
📡 Connecting to hotspot: MarkusPhone...
⏳ Waiting for Wi-Fi connection to stabilize...
✅ Detected WiFi connection. IP Address: 172.20.10.5
⏱ Connected for: 00:03:45
```

## 📂 License

MIT License — feel free to use, modify, and share.

