#!/bin/bash
# Launch Gitea web interface in browser

echo "🚀 Gitea Web Interface Access"
echo ""

# Since this runs on the VM, we can't open the user's local browser
# Instead, provide clear instructions on how to access Gitea

echo "🌐 Gitea is running on this VM at: http://localhost:3000"
echo ""

# Try to get the actual IP addresses for better UX
# Since this runs on the VM, we need to get IPs from the deployment context
WIREGUARD_IP=""
MYCELIUM_IP=""

# Check if tfgrid-compose is available and try to get addresses
if command -v tfgrid-compose >/dev/null 2>&1; then
    # Try with app name first (more reliable), then without
    ADDRESS_OUTPUT=$(tfgrid-compose address tfgrid-gitea 2>/dev/null || tfgrid-compose address 2>/dev/null || echo "")
    if [ -n "$ADDRESS_OUTPUT" ]; then
        WIREGUARD_IP=$(echo "$ADDRESS_OUTPUT" | grep "Wireguard IP:" | sed 's/Wireguard IP: //' | xargs)
        MYCELIUM_IP=$(echo "$ADDRESS_OUTPUT" | grep "Mycelium IP:" | sed 's/Mycelium IP: //' | xargs)

        # If not found with that pattern, try alternative patterns
        if [ -z "$WIREGUARD_IP" ]; then
            WIREGUARD_IP=$(echo "$ADDRESS_OUTPUT" | grep "WireGuard:" | sed 's/WireGuard: //' | xargs)
        fi
        if [ -z "$MYCELIUM_IP" ]; then
            MYCELIUM_IP=$(echo "$ADDRESS_OUTPUT" | grep "Mycelium:" | sed 's/Mycelium: //' | xargs)
        fi
    fi
fi

# If still not found, try to get from system (WireGuard interface)
if [ -z "$WIREGUARD_IP" ]; then
    # Check if wg1 interface exists and get its IP
    if ip link show wg1 >/dev/null 2>&1; then
        WIREGUARD_IP=$(ip -4 addr show wg1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
    fi
fi

echo "📋 Access URLs:"
if [ -n "$WIREGUARD_IP" ]; then
    echo "   🔗 WireGuard:  http://$WIREGUARD_IP:3000"
fi
if [ -n "$MYCELIUM_IP" ]; then
    echo "   🔗 Mycelium:   http://[$MYCELIUM_IP]:3000"
fi
echo ""

if [ -z "$WIREGUARD_IP" ] && [ -z "$MYCELIUM_IP" ]; then
    echo "📋 To find the access URLs:"
    echo "   Run: tfgrid-compose address tfgrid-gitea"
    echo "   Then visit: http://<IP>:3000"
    echo ""
fi

echo "🔑 Default login credentials:"
echo "   Username: gitadmin"
echo "   Password: changeme123"
echo ""
echo "⚠️  Remember to change the default password after first login!"
echo ""
echo "✅ Gitea is ready to use"