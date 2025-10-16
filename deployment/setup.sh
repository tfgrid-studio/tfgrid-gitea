#!/usr/bin/env bash
# Setup script - Install Gitea and dependencies
# This runs on the VM during deployment

set -e

echo "🚀 Setting up tfgrid-gitea..."

# Update system
echo "📦 Updating system..."
apt-get update

# Install dependencies
echo "📦 Installing dependencies..."
apt-get install -y git sqlite3 curl wget

# Create gitea user
echo "👤 Creating gitea user..."
if ! id -u git >/dev/null 2>&1; then
    useradd -m -s /bin/bash git
    echo "✅ Created git user"
else
    echo "ℹ️  Git user already exists"
fi

# Create directories
echo "📁 Creating directories..."
mkdir -p /var/lib/gitea/{custom,data,log}
mkdir -p /etc/gitea
chown -R git:git /var/lib/gitea
chown -R git:git /etc/gitea
chmod 750 /var/lib/gitea
chmod 750 /etc/gitea

# Download Gitea binary
echo "📥 Downloading Gitea..."
GITEA_VERSION="1.21.0"
wget -O /usr/local/bin/gitea https://dl.gitea.com/gitea/${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64
chmod +x /usr/local/bin/gitea

# Verify installation
echo "🔍 Verifying Gitea installation..."
if command -v gitea &> /dev/null; then
    echo "✅ Gitea installed: $(gitea --version | head -1)"
else
    echo "❌ Gitea installation failed"
    exit 1
fi

echo "✅ Setup complete"
echo "👤 Git user ready"
echo "📁 Data directory: /var/lib/gitea"
