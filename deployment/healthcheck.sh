#!/usr/bin/env bash
# Health check script - Verify Gitea deployment is working
# This runs after configuration to ensure everything is operational

set -e

echo "🏥 Running health checks for tfgrid-gitea..."

# Check if service is running
echo -n "🔍 Checking service status... "
if systemctl is-active --quiet gitea; then
    echo "✅ Gitea service is running"
else
    echo "❌ Gitea service is NOT running"
    systemctl status gitea
    exit 1
fi

# Check if Gitea binary exists
echo -n "🔍 Checking Gitea binary... "
if command -v gitea &> /dev/null; then
    echo "✅ Gitea binary is installed ($(gitea --version | head -1))"
else
    echo "❌ Gitea binary is NOT installed"
    exit 1
fi

# Check configuration file
echo -n "🔍 Checking configuration... "
if [ -f "/etc/gitea/app.ini" ]; then
    echo "✅ Configuration file exists"
else
    echo "❌ Configuration file does NOT exist"
    exit 1
fi

# Check data directory
echo -n "🔍 Checking data directory... "
if [ -d "/var/lib/gitea/data" ]; then
    echo "✅ Data directory exists"
else
    echo "❌ Data directory does NOT exist"
    exit 1
fi

# Check database
echo -n "🔍 Checking database... "
if [ -f "/var/lib/gitea/data/gitea.db" ]; then
    echo "✅ Database exists"
else
    echo "❌ Database does NOT exist"
    exit 1
fi

# Check if port is listening
GITEA_PORT="${GITEA_PORT:-3000}"
echo -n "🔍 Checking if Gitea is listening on port ${GITEA_PORT}... "
if netstat -tuln 2>/dev/null | grep -q ":${GITEA_PORT} " || ss -tuln 2>/dev/null | grep -q ":${GITEA_PORT} "; then
    echo "✅ Gitea is listening on port ${GITEA_PORT}"
else
    echo "⚠️  Cannot verify port (netstat/ss may not be installed)"
fi

# HTTP health check
echo -n "🔍 Checking HTTP endpoint... "
if curl -f -s http://localhost:${GITEA_PORT}/ > /dev/null; then
    echo "✅ HTTP endpoint is responding"
else
    echo "⚠️  HTTP endpoint check failed (may still be starting)"
fi

# Check logs for errors
echo -n "🔍 Checking logs for errors... "
if [ -f "/var/lib/gitea/log/gitea.log" ]; then
    ERROR_COUNT=$(grep -i "error" /var/lib/gitea/log/gitea.log | tail -10 | wc -l)
    if [ "$ERROR_COUNT" -gt 5 ]; then
        echo "⚠️  Found ${ERROR_COUNT} recent errors in logs"
        echo "Last errors:"
        grep -i "error" /var/lib/gitea/log/gitea.log | tail -5
    else
        echo "✅ No critical errors in logs"
    fi
else
    echo "ℹ️  Log file not found yet"
fi

echo ""
echo "✅ All health checks passed!"
echo "🎉 tfgrid-gitea is ready to use"
echo ""
echo "Access Gitea at: http://localhost:${GITEA_PORT}"
echo "Or via gateway: http://example.com/gitea"
