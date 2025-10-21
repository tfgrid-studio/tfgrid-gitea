#!/bin/bash
# Check Gitea service status

echo "📊 Gitea Service Status"
echo "======================"

# Systemd status
echo "🔧 Systemd Status:"
systemctl status gitea --no-pager -l

echo ""
echo "🌐 Web Interface:"
if curl -f http://localhost:3000/api/v1/version >/dev/null 2>&1; then
    echo "✅ Responding at http://localhost:3000"
else
    echo "❌ Not responding"
fi

echo ""
echo "💾 Database:"
if [ -f /var/lib/gitea/data/gitea.db ]; then
    echo "✅ SQLite database exists"
    ls -lh /var/lib/gitea/data/gitea.db
else
    echo "❌ Database not found"
fi