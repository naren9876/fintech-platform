#!/bin/bash
set -euo pipefail

echo "Running Bootstrap Terraform..."

cd bootstrap/terraform

terraform init

terraform plan -out=tfplan

terraform apply -input=false tfplan

echo "✅ Bootstrap Terraform completed"

echo ""
echo "Extracting outputs..."

BUCKETS=$(terraform output -json state_buckets)
SA_EMAIL=$(terraform output -raw service_account_email)
SA_KEY=$(terraform output -raw service_account_key)

echo "State Buckets:"
echo "$BUCKETS" | jq .

echo ""
echo "Service Account Email: $SA_EMAIL"

mkdir -p /tmp/gcp-keys
echo "$SA_KEY" > /tmp/gcp-keys/github-actions-key.json

echo "✅ Service account key saved to /tmp/gcp-keys/github-actions-key.json"
