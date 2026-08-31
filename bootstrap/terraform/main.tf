terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

locals {
  environments = {
    dev = {
      name = "dev"
    }
    staging = {
      name = "staging"
    }
    prod = {
      name = "prod"
    }
  }
}

resource "google_storage_bucket" "terraform_state" {
  for_each = local.environments
  
  name          = "fintech-terraform-state-${each.key}"
  location      = var.gcp_region
  project       = var.gcp_project_id
  force_destroy = false
  
  versioning {
    enabled = true
  }
  
  uniform_bucket_level_access {
    enabled = true
  }
  
  labels = {
    environment = each.key
    managed_by  = "terraform"
  }
}

resource "google_service_account" "github_actions" {
  project      = var.gcp_project_id
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account"
}

resource "google_project_iam_member" "github_actions_editor" {
  project = var.gcp_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_service_account_key" "github_actions" {
  service_account_id = google_service_account.github_actions.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

output "state_buckets" {
  value = {
    for env, bucket in google_storage_bucket.terraform_state :
    env => bucket.name
  }
  description = "Terraform state buckets"
}

output "service_account_email" {
  value       = google_service_account.github_actions.email
  description = "GitHub Actions service account email"
}

output "service_account_key" {
  value       = google_service_account_key.github_actions.private_key
  sensitive   = true
  description = "GitHub Actions service account private key"
}
