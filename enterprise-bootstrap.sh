#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}  $1"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

print_step() {
  echo -e "\n${YELLOW}▶ $1${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
  exit 1
}

print_header "ENTERPRISE BOOTSTRAP - FULL AUTOMATION"

print_step "Checking prerequisites..."
command -v terraform >/dev/null 2>&1 || print_error "terraform not found"
command -v gcloud >/dev/null 2>&1 || print_error "gcloud not found"
print_success "All tools found"

print_step "Requesting credentials..."
read -p "GitHub Repository (owner/repo): " GITHUB_REPO
read -sp "GitHub Personal Access Token: " GITHUB_TOKEN
echo ""

if [ -z "$GITHUB_REPO" ] || [ -z "$GITHUB_TOKEN" ]; then
  print_error "Credentials required"
fi

print_success "Credentials provided"

print_header "PHASE 1: Bootstrap GCP Infrastructure"

print_step "Initializing Terraform..."
cd ~/fintech-platform/bootstrap/terraform
terraform init -upgrade

print_step "Planning infrastructure..."
terraform plan -out=tfplan

print_step "Applying infrastructure..."
terraform apply -input=false tfplan

print_success "GCP infrastructure created"

print_header "PHASE 2: Extract Outputs"

print_step "Extracting service account key..."
mkdir -p /tmp/gcp-keys
terraform output -raw service_account_key > /tmp/gcp-keys/github-actions-key.json

BUCKETS=$(terraform output -json state_buckets)
SA_EMAIL=$(terraform output -raw service_account_email)

echo ""
echo "State Buckets:"
echo "$BUCKETS" | jq '.'
echo ""
echo "Service Account: $SA_EMAIL"

print_success "Outputs extracted"

print_header "PHASE 3: Add GitHub Secrets (Terraform)"

print_step "Planning GitHub resources..."
terraform plan \
  -var="github_token=$GITHUB_TOKEN" \
  -var="github_repository=$GITHUB_REPO" \
  -out=tfplan-github

print_step "Applying GitHub secrets..."
terraform apply -input=false tfplan-github

print_success "GitHub secrets created via Terraform"

print_header "PHASE 4: Verification"

print_step "Verifying GCP buckets..."
for ENV in dev staging prod; do
  if gsutil ls "gs://fintech-terraform-state-${ENV}" >/dev/null 2>&1; then
    print_success "Bucket: fintech-terraform-state-${ENV}"
  else
    print_error "Bucket NOT found: fintech-terraform-state-${ENV}"
  fi
done

print_step "Verifying service account..."
if gcloud iam service-accounts describe github-actions@fintech-dev-001.iam.gserviceaccount.com >/dev/null 2>&1; then
  print_success "Service account created"
else
  print_error "Service account NOT found"
fi

print_header "PHASE 5: Trigger Pipeline"

print_step "Pushing to GitHub..."
cd ~/fintech-platform
git commit --allow-empty -m "trigger: enterprise deployment"
git push origin main

print_success "Pipeline triggered"

print_header "✅ ENTERPRISE BOOTSTRAP COMPLETE"

echo ""
echo -e "${GREEN}Everything automated with Terraform!${NC}"
echo ""
echo -e "${YELLOW}What was created:${NC}"
echo "✅ GCP state buckets (dev/staging/prod)"
echo "✅ Service account"
echo "✅ GitHub secrets (via Terraform)"
echo "✅ GitHub Actions pipeline triggered"
echo ""
echo -e "${YELLOW}Monitor at:${NC}"
echo "https://github.com/$GITHUB_REPO/actions"
echo ""

