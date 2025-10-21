#!/bin/bash
# Create a new repository in Gitea

set -e

# Default values
REPO_NAME=""
DESCRIPTION=""
PRIVATE=false
AUTO_INIT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --private)
            PRIVATE=true
            shift
            ;;
        --description=*)
            DESCRIPTION="${1#*=}"
            shift
            ;;
        --auto-init)
            AUTO_INIT=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Usage: $0 <repo-name> [--private] [--description='desc'] [--auto-init]"
            exit 1
            ;;
        *)
            if [ -z "$REPO_NAME" ]; then
                REPO_NAME="$1"
            else
                echo "Too many arguments. Usage: $0 <repo-name> [--private] [--description='desc'] [--auto-init]"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$REPO_NAME" ]; then
    echo "Repository name is required"
    echo "Usage: $0 <repo-name> [--private] [--description='desc'] [--auto-init]"
    exit 1
fi

echo "📝 Creating repository: $REPO_NAME"

# Get admin credentials from environment or prompt
ADMIN_USER="${GITEA_ADMIN_USER:-gitadmin}"
ADMIN_TOKEN="${GITEA_ADMIN_TOKEN:-}"

if [ -z "$ADMIN_TOKEN" ]; then
    echo "Admin token required. Set GITEA_ADMIN_TOKEN or ensure admin user exists."
    echo "You can create an admin user first with: tfgrid-compose init tfgrid-gitea"
    exit 1
fi

# Prepare JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "name": "$REPO_NAME",
    "description": "$DESCRIPTION",
    "private": $PRIVATE,
    "auto_init": $AUTO_INIT
}
EOF
)

# Create repository via API
echo "🚀 Creating repository..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    "http://localhost:3000/api/v1/admin/users/$ADMIN_USER/repos" \
    -H "Content-Type: application/json" \
    -H "Authorization: token $ADMIN_TOKEN" \
    -d "$JSON_PAYLOAD")

# Parse response
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -eq 201 ]; then
    echo "✅ Repository '$REPO_NAME' created successfully!"
    if [ "$PRIVATE" = true ]; then
        echo "🔒 Repository is private"
    else
        echo "🌐 Repository is public"
    fi
    if [ -n "$DESCRIPTION" ]; then
        echo "📝 Description: $DESCRIPTION"
    fi
else
    echo "❌ Failed to create repository (HTTP $HTTP_CODE)"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi

echo ""
echo "🔗 Repository URL: http://localhost:3000/$ADMIN_USER/$REPO_NAME"
echo "📋 Clone URL: http://localhost:3000/$ADMIN_USER/$REPO_NAME.git"