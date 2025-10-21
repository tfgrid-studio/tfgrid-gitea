#!/usr/bin/env bash
# Configure script - Set up Gitea service and configuration
# This runs after setup to configure the systemd service

set -e

echo "⚙️  Configuring tfgrid-gitea..."

# Install systemd service
echo "🔧 Installing systemd service..."
cp /tmp/app-source/src/systemd/gitea.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable gitea

# Create Gitea configuration
echo "⚙️  Creating Gitea configuration..."
cat > /etc/gitea/app.ini << EOF
[server]
HTTP_PORT = 3000
ROOT_URL = http://localhost:3000/

[database]
DB_TYPE = sqlite3
PATH = /var/lib/gitea/data/gitea.db

[security]
INSTALL_LOCK = true
SECRET_KEY = $(openssl rand -hex 32)
INTERNAL_TOKEN = $(openssl rand -hex 32)

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false
EOF

# Set proper ownership
chown gitea:gitea /etc/gitea/app.ini

# Start service
echo "🚀 Starting Gitea service..."
systemctl start gitea

echo "✅ Configuration complete"
echo "🌐 Gitea should be accessible at: http://localhost:3000"
