.PHONY: help validate plan apply destroy clean bootstrap-gcp github-secrets

ENVIRONMENT ?= dev

help:
	@echo "FinTech Platform - Make Commands"
	@echo ""
	@echo "Bootstrap:"
	@echo "  make bootstrap-gcp              Setup GCP infrastructure (Terraform)"
	@echo "  make github-secrets             Add secrets to GitHub"
	@echo ""
	@echo "Operations:"
	@echo "  make validate                   Validate Terraform"
	@echo "  make plan ENV=dev               Plan infrastructure"
	@echo "  make apply ENV=dev              Apply infrastructure"
	@echo "  make destroy ENV=dev            Destroy infrastructure"
	@echo "  make clean                      Clean Terraform files"
	@echo ""

bootstrap-gcp:
	@echo "Setting up GCP infrastructure..."
	@bash scripts/gcp/setup.sh
	@echo "✅ GCP bootstrap complete"

github-secrets:
	@read -p "Enter GitHub repository (owner/repo): " repo; \
	read -sp "Enter GitHub token: " token; \
	echo ""; \
	bash scripts/github/add-secrets.sh "$$repo" "$$token"

validate:
	cd terraform && terraform fmt -check -recursive
	cd terraform && terraform init -backend=false && terraform validate

plan:
	cd terraform && \
	terraform init -backend-config="bucket=fintech-terraform-state-$(ENVIRONMENT)" && \
	terraform plan -var-file="environments/$(ENVIRONMENT).tfvars"

apply:
	cd terraform && \
	terraform init -backend-config="bucket=fintech-terraform-state-$(ENVIRONMENT)" && \
	terraform apply -auto-approve -var-file="environments/$(ENVIRONMENT).tfvars"

destroy:
	cd terraform && \
	terraform init -backend-config="bucket=fintech-terraform-state-$(ENVIRONMENT)" && \
	terraform destroy -auto-approve -var-file="environments/$(ENVIRONMENT).tfvars"

clean:
	find terraform -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find terraform -name "*.tfstate*" -delete
	find terraform -name ".terraform.lock.hcl" -delete
	find . -name "tfplan*" -delete
	rm -rf bootstrap/terraform/.terraform
	rm -f bootstrap/terraform/terraform.tfstate*
