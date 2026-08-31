#!/bin/bash
set -euo pipefail

GITHUB_REPO="${1:-}"
GITHUB_TOKEN="${2:-}"

if [ -z "$GITHUB_REPO" ] || [ -z "$GITHUB_TOKEN" ]; then
  echo "Usage: $0 <owner/repo> <github-token>"
  exit 1
fi

echo "Adding GitHub secrets for: $GITHUB_REPO"

SA_KEY=$(cat /tmp/gcp-keys/github-actions-key.json)

for ENV in dev staging prod; do
  echo "Adding GCP_SA_KEY_${ENV^^}..."
  
  RESPONSE=$(curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_REPO/actions/secrets/GCP_SA_KEY_${ENV^^}" \
    -d "{\"encrypted_value\":\"$(echo -n "$SA_KEY" | base64)\"}" \
    -w "\n%{http_code}")
  
  HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
  
  if [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "204" ]; then
    echo "✅ GCP_SA_KEY_${ENV^^} added"
  else
    echo "❌ Failed to add GCP_SA_KEY_${ENV^^} (HTTP $HTTP_CODE)"
  fi
done

echo "✅ All secrets added to GitHub"
