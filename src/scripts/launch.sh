#!/bin/bash
# Launch Gitea web interface in browser

echo "🚀 Gitea Web Interface Access"
echo ""

# Since this runs on the VM, we can't open the user's local browser
# Instead, provide clear instructions on how to access Gitea

echo "🌐 Gitea is running on this VM at: http://localhost:3000"
echo ""
echo "📋 To access Gitea from your local machine:"
echo ""
echo "1. Get the VM's external IP:"
echo "   tfgrid-compose address tfgrid-gitea"
echo ""
echo "2. Open your browser and go to:"
echo "   http://<VM_IP>:3000"
echo ""
echo "   Where <VM_IP> is the WireGuard IP or Mycelium IP from step 1"
echo ""
echo "🔑 Default login credentials:"
echo "   Username: gitadmin"
echo "   Password: changeme123"
echo ""
echo "⚠️  Remember to change the default password after first login!"
echo ""
echo "✅ Gitea is ready to use"