#!/usr/bin/env bash
# Configure script - Set up Gitea service and configuration
# This runs after setup to configure the systemd service

set -e

echo "⚙️  Configuring tfgrid-gitea..."

# Systemd service was already installed by setup.sh
echo "🔧 Systemd service already installed"

# Create Gitea configuration
echo "⚙️  Creating Gitea configuration..."

# Determine ROOT_URL based on available IPs
ROOT_URL="http://localhost:3000/"
if [ -n "${TFGRID_WIREGUARD_IP:-}" ]; then
    ROOT_URL="http://${TFGRID_WIREGUARD_IP}:3000/"
elif [ -n "${TFGRID_MYCELIUM_IP:-}" ]; then
    ROOT_URL="http://[${TFGRID_MYCELIUM_IP}]:3000/"
fi

cat > /etc/gitea/app.ini << EOF
WORK_PATH = /var/lib/gitea

[server]
HTTP_PORT = 3000
ROOT_URL = ${ROOT_URL}

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

[oauth2]
JWT_SECRET = $(openssl rand -hex 32)
EOF

# Set proper ownership
chown gitea:gitea /etc/gitea/app.ini

# Start service temporarily to initialize database
echo "🚀 Starting Gitea service to initialize..."
systemctl start gitea

# Wait for Gitea to initialize
echo "⏳ Waiting for Gitea to initialize database..."
sleep 5

# Create admin user
echo "👤 Creating admin user..."
GITEA_ADMIN_USER="${GITEA_ADMIN_USER:-gitadmin}"
GITEA_ADMIN_PASSWORD="${GITEA_ADMIN_PASSWORD:-changeme123}"
GITEA_ADMIN_EMAIL="${GITEA_ADMIN_EMAIL:-admin@localhost}"

# Create admin using Gitea CLI
sudo -u gitea /usr/local/bin/gitea admin user create \
    --username "$GITEA_ADMIN_USER" \
    --password "$GITEA_ADMIN_PASSWORD" \
    --email "$GITEA_ADMIN_EMAIL" \
    --admin \
    --config /etc/gitea/app.ini \
    || echo "⚠️  Admin user may already exist"

echo "✅ Configuration complete"
echo "🌐 Gitea accessible at: ${ROOT_URL}"
echo "👤 Admin user: $GITEA_ADMIN_USER"
echo "🔑 Admin password: $GITEA_ADMIN_PASSWORD"
echo "⚠️  Change the password after first login!"
