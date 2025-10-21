#!/bin/bash
# Launch Gitea web interface in browser

set -e

echo "🚀 Launching Gitea web interface..."

# Get the VM's accessible IP
# Try WireGuard first, then Mycelium
VM_IP=""

# Check if we're running on the VM itself
if [ -f /etc/gitea/app.ini ]; then
    # Running on VM - use localhost
    VM_IP="localhost"
else
    # Running locally - need to get VM IP from tfgrid-compose
    echo "Detecting VM IP..."

    # Try to get IP from tfgrid-compose address command
    # This assumes we're in the correct directory or have context
    if command -v tfgrid-compose >/dev/null 2>&1; then
        ADDRESS_OUTPUT=$(tfgrid-compose address tfgrid-gitea 2>/dev/null || echo "")
        if [ -n "$ADDRESS_OUTPUT" ]; then
            # Parse the output to extract IP
            # tfgrid-compose address typically outputs something like:
            # WireGuard: 100.64.x.x
            # Mycelium: xxx.xxx.xxx.xxx
            WIREGUARD_IP=$(echo "$ADDRESS_OUTPUT" | grep "WireGuard:" | sed 's/WireGuard: //' | xargs)
            MYCELIUM_IP=$(echo "$ADDRESS_OUTPUT" | grep "Mycelium:" | sed 's/Mycelium: //' | xargs)

            # Prefer WireGuard, fallback to Mycelium
            if [ -n "$WIREGUARD_IP" ]; then
                VM_IP="$WIREGUARD_IP"
            elif [ -n "$MYCELIUM_IP" ]; then
                VM_IP="$MYCELIUM_IP"
            fi
        fi
    fi

    # If we couldn't get IP from tfgrid-compose, try environment or prompt
    if [ -z "$VM_IP" ]; then
        echo "Could not automatically detect VM IP."
        echo "Please provide the VM IP (WireGuard or Mycelium):"
        read -r VM_IP
    fi
fi

if [ -z "$VM_IP" ]; then
    echo "❌ Could not determine VM IP"
    exit 1
fi

# Construct URL
GITEA_URL="http://$VM_IP:3000"

echo "🌐 Opening Gitea at: $GITEA_URL"

# Open in browser (cross-platform)
if command -v xdg-open >/dev/null 2>&1; then
    # Linux
    xdg-open "$GITEA_URL" 2>/dev/null &
elif command -v open >/dev/null 2>&1; then
    # macOS
    open "$GITEA_URL" 2>/dev/null &
elif command -v start >/dev/null 2>&1; then
    # Windows (in WSL)
    start "$GITEA_URL" 2>/dev/null &
else
    echo "⚠️  Could not open browser automatically."
    echo "Please manually open: $GITEA_URL"
fi

echo "✅ Browser launch initiated"