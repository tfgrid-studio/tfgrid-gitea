#!/usr/bin/env bash
# Configure script - Set up Gitea service and configuration
# This runs after setup to configure Gitea

set -e

echo "⚙️  Configuring tfgrid-gitea..."

# Get environment variables with defaults
GITEA_ADMIN_USER="${GITEA_ADMIN_USER:-gitadmin}"
GITEA_ADMIN_PASSWORD="${GITEA_ADMIN_PASSWORD:-changeme123}"
GITEA_ADMIN_EMAIL="${GITEA_ADMIN_EMAIL:-admin@localhost}"
GITEA_DOMAIN="${GITEA_DOMAIN:-localhost}"
GITEA_PORT="${GITEA_PORT:-3000}"

# Create Gitea configuration
echo "📝 Creating Gitea configuration..."
cat > /etc/gitea/app.ini << EOF
APP_NAME = TFGrid Gitea
RUN_USER = git
RUN_MODE = prod

[server]
PROTOCOL = http
DOMAIN = ${GITEA_DOMAIN}
ROOT_URL = http://${GITEA_DOMAIN}:${GITEA_PORT}/
HTTP_PORT = ${GITEA_PORT}
DISABLE_SSH = false
SSH_PORT = 22
START_SSH_SERVER = false
OFFLINE_MODE = false

[database]
DB_TYPE = sqlite3
PATH = /var/lib/gitea/data/gitea.db
LOG_SQL = false

[repository]
ROOT = /var/lib/gitea/data/git/repositories
DEFAULT_BRANCH = main

[log]
MODE = file
LEVEL = Info
ROOT_PATH = /var/lib/gitea/log

[security]
INSTALL_LOCK = true
SECRET_KEY = $(gitea generate secret SECRET_KEY)
INTERNAL_TOKEN = $(gitea generate secret INTERNAL_TOKEN)

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false
ENABLE_CAPTCHA = false

[oauth2]
ENABLE = true
JWT_SECRET = $(gitea generate secret JWT_SECRET)

[api]
ENABLE_SWAGGER = true
EOF

# Set proper permissions
chown git:git /etc/gitea/app.ini
chmod 640 /etc/gitea/app.ini

# Create systemd service
echo "📝 Creating systemd service..."
cat > /etc/systemd/system/gitea.service << 'EOF'
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target

[Service]
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
RestartSec=10
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
echo "🔄 Reloading systemd..."
systemctl daemon-reload

# Enable and start service
echo "▶️  Starting Gitea service..."
systemctl enable gitea
systemctl start gitea

# Wait for Gitea to start
echo "⏳ Waiting for Gitea to start..."
sleep 5

# Create admin user
echo "👤 Creating admin user..."
su - git -c "gitea admin user create --username ${GITEA_ADMIN_USER} --password ${GITEA_ADMIN_PASSWORD} --email ${GITEA_ADMIN_EMAIL} --admin --config /etc/gitea/app.ini" 2>/dev/null || echo "ℹ️  Admin user may already exist"

echo "✅ Configuration complete"
echo "🌐 Gitea is available at: http://${GITEA_DOMAIN}:${GITEA_PORT}"
echo "👤 Admin user: ${GITEA_ADMIN_USER}"
echo "🔑 Admin password: ${GITEA_ADMIN_PASSWORD}"
