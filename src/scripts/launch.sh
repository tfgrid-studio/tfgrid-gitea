#!/bin/bash
# Launch Gitea web interface in browser

echo "🚀 Gitea Web Interface Access"
echo ""

# Since this runs on the VM, we can't open the user's local browser
# Instead, provide clear instructions on how to access Gitea

echo "🌐 Gitea is running on this VM at: http://localhost:3000"
echo ""

# Source TFGrid environment variables if available
if [ -f /etc/profile.d/tfgrid-env.sh ]; then
    source /etc/profile.d/tfgrid-env.sh
fi

# Try to get the actual IP addresses for better UX
# Priority 1: Environment variables set by tfgrid-compose during deployment
WIREGUARD_IP="${TFGRID_WIREGUARD_IP:-}"
MYCELIUM_IP="${TFGRID_MYCELIUM_IP:-}"

# Priority 2: If not set, try to detect from system network interfaces
if [ -z "$WIREGUARD_IP" ]; then
    # Check for WireGuard interfaces (wg0, wg1, wg2, etc.)
    for wg_iface in $(ip link show | grep -o 'wg[0-9]\+' | sort -u); do
        if ip link show "$wg_iface" >/dev/null 2>&1; then
            WIREGUARD_IP=$(ip -4 addr show "$wg_iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$WIREGUARD_IP" ]; then
                break
            fi
        fi
    done
fi

if [ -z "$MYCELIUM_IP" ]; then
    # Check if mycelium interface exists and get its IPv6 address
    if ip link show mycelium >/dev/null 2>&1; then
        MYCELIUM_IP=$(ip -6 addr show mycelium | grep -oP '(?<=inet6\s)[0-9a-f:]+(?=/)' | head -1)
    fi
fi

# Priority 3: Additional fallback for IPv4 addresses on common interfaces
if [ -z "$WIREGUARD_IP" ]; then
    # Look for IPv4 addresses on eth0, ens3, enp0s3, or other common interfaces
    for iface in eth0 ens3 enp0s3 ens4 ens5; do
        if ip link show "$iface" >/dev/null 2>&1; then
            WIREGUARD_IP=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$WIREGUARD_IP" ]; then
                break
            fi
        fi
    done
fi

# Debug: Show what we found
if [ -n "$WIREGUARD_IP" ] || [ -n "$MYCELIUM_IP" ]; then
    echo "🔍 Detected IP addresses:"
    [ -n "$WIREGUARD_IP" ] && echo "   WireGuard: $WIREGUARD_IP"
    [ -n "$MYCELIUM_IP" ] && echo "   Mycelium: $MYCELIUM_IP"
    echo ""
fi

echo "� Access URLs:"
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