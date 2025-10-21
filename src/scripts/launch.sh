#!/bin/bash
# Launch Gitea web interface in browser

echo "🚀 Gitea Web Interface Access"
echo ""

# Since this runs on the VM, we can't open the user's local browser
# Instead, provide clear instructions on how to access Gitea

echo "🌐 Gitea is running on this VM at: http://localhost:3000"
echo ""

# Try to get the actual IP addresses for better UX
# First check environment variables that tfgrid-compose might pass
WIREGUARD_IP="${TFGRID_WIREGUARD_IP:-}"
MYCELIUM_IP="${TFGRID_MYCELIUM_IP:-}"

# If not set, try to get from tfgrid-compose address command
if [ -z "$WIREGUARD_IP" ] && [ -z "$MYCELIUM_IP" ] && command -v tfgrid-compose >/dev/null 2>&1; then
    ADDRESS_OUTPUT=$(tfgrid-compose address tfgrid-gitea 2>/dev/null || echo "")
    if [ -n "$ADDRESS_OUTPUT" ]; then
        WIREGUARD_IP=$(echo "$ADDRESS_OUTPUT" | grep "Wireguard IP:" | sed 's/Wireguard IP: //' | xargs)
        MYCELIUM_IP=$(echo "$ADDRESS_OUTPUT" | grep "Mycelium IP:" | sed 's/Mycelium IP: //' | xargs)
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