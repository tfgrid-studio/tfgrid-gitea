#!/bin/bash
# Initialize admin user in Gitea

echo "👑 Initializing Gitea admin user..."

# Wait for Gitea to be ready
sleep 10

# Create admin user via API
curl -X POST "http://localhost:3000/api/v1/admin/users" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"${GITEA_ADMIN_USER:-gitadmin}\",
    \"email\": \"${GITEA_ADMIN_EMAIL:-admin@localhost}\",
    \"password\": \"${GITEA_ADMIN_PASSWORD:-changeme123}\",
    \"must_change_password\": false
  }" 2>/dev/null || echo "Admin user may already exist"

echo "✅ Admin user initialized"
echo "🔐 Username: ${GITEA_ADMIN_USER:-gitadmin}"
echo "🔑 Password: ${GITEA_ADMIN_PASSWORD:-changeme123}"
echo "⚠️  CHANGE THE PASSWORD IMMEDIATELY!"