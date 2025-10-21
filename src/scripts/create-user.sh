#!/bin/bash
# Create a new user in Gitea

set -e

# Parse arguments
USERNAME=""
EMAIL=""
IS_ADMIN=false
PASSWORD=""

if [ $# -lt 2 ]; then
    echo "Usage: $0 <username> <email> [--admin]"
    exit 1
fi

USERNAME="$1"
EMAIL="$2"
shift 2

# Parse optional flags
while [[ $# -gt 0 ]]; do
    case $1 in
        --admin)
            IS_ADMIN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 <username> <email> [--admin]"
            exit 1
            ;;
    esac
done

echo "👤 Creating user: $USERNAME ($EMAIL)"

# Get admin credentials
ADMIN_TOKEN="${GITEA_ADMIN_TOKEN:-}"

if [ -z "$ADMIN_TOKEN" ]; then
    echo "Admin token required. Set GITEA_ADMIN_TOKEN environment variable."
    echo "You can create an admin user first with: tfgrid-compose init tfgrid-gitea"
    exit 1
fi

# Generate a random password if not provided
if [ -z "$PASSWORD" ]; then
    PASSWORD=$(openssl rand -base64 12)
fi

# Prepare JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "username": "$USERNAME",
    "email": "$EMAIL",
    "password": "$PASSWORD",
    "must_change_password": true,
    "admin": $IS_ADMIN
}
EOF
)

# Create user via API
echo "🚀 Creating user..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    "http://localhost:3000/api/v1/admin/users" \
    -H "Content-Type: application/json" \
    -H "Authorization: token $ADMIN_TOKEN" \
    -d "$JSON_PAYLOAD")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 201 ]; then
    echo "✅ User '$USERNAME' created successfully!"
    echo "📧 Email: $EMAIL"
    if [ "$IS_ADMIN" = true ]; then
        echo "👑 Admin privileges: Yes"
    else
        echo "👤 Admin privileges: No"
    fi
    echo ""
    echo "🔐 Temporary password: $PASSWORD"
    echo "⚠️  User must change password on first login!"
    echo ""
    echo "🔗 User profile: http://localhost:3000/$USERNAME"
else
    echo "❌ Failed to create user (HTTP $HTTP_CODE)"
    echo "Response: $RESPONSE_BODY"

    # Check for common errors
    if echo "$RESPONSE_BODY" | grep -q "user already exists"; then
        echo "💡 User '$USERNAME' already exists"
    elif echo "$RESPONSE_BODY" | grep -q "email already exists"; then
        echo "💡 Email '$EMAIL' is already registered"
    fi

    exit 1
fi