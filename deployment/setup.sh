#!/usr/bin/env bash
# Setup script - Install Gitea and dependencies
# This runs on the VM during deployment

set -e

echo "🚀 Setting up tfgrid-gitea..."

# Install system dependencies
echo "📦 Installing system dependencies..."
apt-get update
apt-get install -y git curl wget sqlite3

# Create gitea user
echo "👤 Creating gitea user..."
if ! id -u gitea >/dev/null 2>&1; then
    useradd -m -s /bin/bash gitea
    echo "✅ Created gitea user"
else
    echo "ℹ️  Gitea user already exists"
fi

# Download and install Gitea
echo "📦 Installing Gitea..."
GITEA_VERSION="1.24.6"
curl -fsSL "https://github.com/go-gitea/gitea/releases/download/v${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64" -o gitea
mv gitea /usr/local/bin/
chmod +x /usr/local/bin/gitea

# Create directories
echo "📁 Creating directories..."
mkdir -p /etc/gitea /var/lib/gitea/data /var/log/gitea
chown -R gitea:gitea /etc/gitea /var/lib/gitea /var/log/gitea

# Create gitea scripts directory
echo "📁 Creating scripts directory..."
mkdir -p /opt/gitea/scripts
cp -r /tmp/app-source/src/scripts/* /opt/gitea/scripts/ 2>/dev/null || echo "ℹ️  No scripts to copy yet"
chmod +x /opt/gitea/scripts/*.sh 2>/dev/null || true

# Install systemd service
echo "🔧 Installing systemd service..."
cp /tmp/app-source/systemd/gitea.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable gitea

echo "✅ Setup complete"
echo "👤 Gitea user ready: /home/gitea"
echo "🔧 Gitea binary: /usr/local/bin/gitea"
echo "🔧 Systemd service: gitea.service"
