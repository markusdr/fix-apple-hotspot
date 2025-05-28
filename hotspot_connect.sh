#!/bin/bash

# --- Configuration ---
INTERFACE="en0"
WAIT_INTERVAL=5
MAX_ATTEMPTS=10
TIMER_INTERVAL=1
HOTSPOT_NAME_VAR="HOTSPOT_NAME"
HOTSPOT_PASSWORD_VAR="HOTSPOT_PASSWORD"
CMDLINE_HOTSPOT_NAME=""
CMDLINE_HOTSPOT_PASSWORD=""

# --- Help Function ---
print_help() {
  echo ""
  echo "📡 macOS Hotspot Connection Script"
  echo ""
  echo "Usage:"
  echo "  export HOTSPOT_NAME='YourHotspotSSID'"
  echo "  export HOTSPOT_PASSWORD='YourHotspotPassword'"
  echo "  ./connect_hotspot.sh [options]"
  echo ""
  echo "Options:"
  echo "  --ssid NAME       Specify hotspot SSID (will prompt for password)"
  echo "  --help            Show this help message"
  echo ""
  echo "Behavior:"
  echo "  ✅ Enables Wi-Fi if disabled"
  echo "  ✅ Disables IPv6 before connecting for stability"
  echo "  ✅ Connects to the specified hotspot"
  echo "  ✅ Displays a live connection timer"
  echo "  ✅ Re-enables IPv6 on exit (Ctrl+C)"
  echo ""
  exit 0
}

# --- Parse Arguments ---
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --ssid)
      shift
      CMDLINE_HOTSPOT_NAME="$1"
      ;;
    --help) print_help ;;
    *) echo "❌ Unknown option: $1"; print_help ;;
  esac
  shift
done

print_sudo_info() {
    if sudo -n true 2>/dev/null; then
	echo "🔐 Admin privileges are active (no password will be prompted)."
    else
	echo "👤 This will ask for your admin (macOS login) password."
    fi
}

# --- Prompt for password if SSID was given via command line ---
if [[ -n "$CMDLINE_HOTSPOT_NAME" ]]; then
  HOTSPOT_NAME="$CMDLINE_HOTSPOT_NAME"
  read -rsp "🔑 Enter password for $HOTSPOT_NAME: " CMDLINE_HOTSPOT_PASSWORD
  echo ""
  HOTSPOT_PASSWORD="$CMDLINE_HOTSPOT_PASSWORD"
else
  # Use environment variables
  if [ -z "${!HOTSPOT_NAME_VAR}" ] || [ -z "${!HOTSPOT_PASSWORD_VAR}" ]; then
    echo "❌ Missing credentials."
    echo "Either:"
    echo "  • Use --ssid to pass hotspot name (will prompt for password), or"
    echo "  • Set env vars HOTSPOT_NAME and HOTSPOT_PASSWORD"
    exit 1
  fi
  HOTSPOT_NAME="${!HOTSPOT_NAME_VAR}"
  HOTSPOT_PASSWORD="${!HOTSPOT_PASSWORD_VAR}"
fi

# --- Determine Correct Interface ---
WIFI_IF=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
if [[ -n "$WIFI_IF" ]]; then
  INTERFACE="$WIFI_IF"
fi
echo "🌐 Network Interface Detected: $INTERFACE"

# --- Turn on Wi-Fi if disabled ---
WIFI_POWER=$(networksetup -getairportpower en0   | awk '{print $NF}')
if [[ "$WIFI_POWER" != "On" ]]; then
  echo "⚡ Wi-Fi is OFF. Turning it ON..."
  networksetup -setairportpower en0 on
  sleep 2
fi

# --- Restart Network Interface ---
echo "🔄 Restarting network interface $INTERFACE..."
print_sudo_info
sudo ifconfig "$INTERFACE" down || { echo "❌ Failed to bring down interface."; exit 1; }
sudo ifconfig "$INTERFACE" up || { echo "❌ Failed to bring up interface."; exit 1; }

# --- Flush DNS Cache ---
echo "🧹 Flushing DNS cache..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# --- Renew DHCP Lease ---
echo "🔄 Renewing DHCP lease..."
sudo ipconfig set "$INTERFACE" DHCP

# --- Disable IPv6 ---
echo "🛑 Disabling IPv6 for better hotspot stability..."
sudo networksetup -setv6off Wi-Fi

# --- Attempt to Connect ---
echo "📡 Connecting to hotspot: $HOTSPOT_NAME..."
networksetup -setairportnetwork "$INTERFACE" "$HOTSPOT_NAME" "$HOTSPOT_PASSWORD"

echo "⏳ Waiting for Wi-Fi connection to stabilize..."
ATTEMPT=0
while [ -z "$(ipconfig getifaddr "$INTERFACE")" ] && [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; do
  ATTEMPT=$((ATTEMPT + 1))
  echo "⚠️  Attempt $ATTEMPT of $MAX_ATTEMPTS: Not connected yet. Make sure Personal Hotspot is discoverable on your iPhone."
  
  # Every 3 attempts, try joining the hotspot again
  if (( ATTEMPT % 3 == 0 )); then
    echo "🔁 Retrying hotspot connection to $HOTSPOT_NAME..."
    networksetup -setairportnetwork "$INTERFACE" "$HOTSPOT_NAME" "$HOTSPOT_PASSWORD"
  fi

  sleep "$WAIT_INTERVAL"
done

# --- Check Final Connection Status ---
IP_ADDR=$(ipconfig getifaddr "$INTERFACE")
if [ -z "$IP_ADDR" ]; then
  echo "❌ Failed to connect after $MAX_ATTEMPTS attempts."
  exit 1
else
  echo "✅ Detected WiFi connection. IP Address: $IP_ADDR"
fi

# --- Live Timer ---
START_TIME=$(date +%s)
display_timer() {
  while true; do
    NOW=$(date +%s)
    ELAPSED=$((NOW - START_TIME))
    printf "\r⏱ Connected for: %02d:%02d:%02d" $((ELAPSED/3600)) $(((ELAPSED/60)%60)) $((ELAPSED%60))
    sleep "$TIMER_INTERVAL"
  done
}

# --- Cleanup Handler ---
cleanup() {
  echo -e "\n🛑 Stopping connection timer..."
  echo "🔄 Re-enabling IPv6..."
  print_sudo_info
  sudo networksetup -setv6automatic Wi-Fi
  echo "✅ Cleanup complete. Exiting."
  exit 0
}
trap cleanup SIGINT SIGTERM

# --- Start Timer and Wait ---
display_timer
