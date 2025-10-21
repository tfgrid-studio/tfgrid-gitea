#!/bin/bash
# List all repositories in Gitea

set -e

echo "📋 Listing repositories..."

# Get admin credentials
ADMIN_USER="${GITEA_ADMIN_USER:-gitadmin}"
ADMIN_TOKEN="${GITEA_ADMIN_TOKEN:-}"

if [ -z "$ADMIN_TOKEN" ]; then
    echo "Admin token required. Set GITEA_ADMIN_TOKEN or ensure admin user exists."
    exit 1
fi

# Get all repositories via API
echo "🔍 Fetching repository list..."
RESPONSE=$(curl -s -w "\n%{http_code}" \
    "http://localhost:3000/api/v1/repos/search?limit=100" \
    -H "Authorization: token $ADMIN_TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" -ne 200 ]; then
    echo "❌ Failed to fetch repositories (HTTP $HTTP_CODE)"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi

# Parse and display repositories
REPO_COUNT=$(echo "$RESPONSE_BODY" | jq -r '.data | length')

if [ "$REPO_COUNT" -eq 0 ]; then
    echo "📭 No repositories found"
    exit 0
fi

echo "📊 Found $REPO_COUNT repositories:"
echo "┌─────────────────────────────────────────────────────────────────────────────────┐"
printf "│ %-30s │ %-15s │ %-10s │ %-15s │\n" "Repository" "Owner" "Private" "Updated"
echo "├─────────────────────────────────────────────────────────────────────────────────┤"

echo "$RESPONSE_BODY" | jq -r '.data[] | @base64' | while read -r repo_data; do
    # Decode the base64 JSON
    repo_json=$(echo "$repo_data" | base64 -d 2>/dev/null || echo "$repo_data" | base64 -D)

    name=$(echo "$repo_json" | jq -r '.name // empty')
    owner=$(echo "$repo_json" | jq -r '.owner.login // empty')
    private=$(echo "$repo_json" | jq -r '.private // false')
    updated=$(echo "$repo_json" | jq -r '.updated_at // empty' | cut -d'T' -f1)

    # Format private flag
    if [ "$private" = "true" ]; then
        private_display="🔒 Yes"
    else
        private_display="🌐 No"
    fi

    # Format full repo name
    full_name="$owner/$name"

    printf "│ %-30s │ %-15s │ %-10s │ %-15s │\n" \
        "${full_name:0:30}" "${owner:0:15}" "$private_display" "$updated"
done

echo "└─────────────────────────────────────────────────────────────────────────────────┘"
echo ""
echo "💡 Use 'tfgrid-compose clone-repo <repo-name>' to clone a repository"