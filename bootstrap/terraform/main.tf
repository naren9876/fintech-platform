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

  repo_name = split("/", var.github_repository)[1]
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

resource "github_actions_secret" "gcp_key_dev" {
  repository      = local.repo_name
  secret_name     = "GCP_SA_KEY_DEV"
  plaintext_value = google_service_account_key.github_actions.private_key
}

resource "github_actions_secret" "gcp_key_staging" {
  repository      = local.repo_name
  secret_name     = "GCP_SA_KEY_STAGING"
  plaintext_value = google_service_account_key.github_actions.private_key
}

resource "github_actions_secret" "gcp_key_prod" {
  repository      = local.repo_name
  secret_name     = "GCP_SA_KEY_PROD"
  plaintext_value = google_service_account_key.github_actions.private_key
}

output "state_buckets" {
  value = {
    for env, bucket in google_storage_bucket.terraform_state :
    env => bucket.name
  }
}

output "service_account_email" {
  value = google_service_account.github_actions.email
}

output "service_account_key" {
  value     = google_service_account_key.github_actions.private_key
  sensitive = true
}

output "github_secrets_created" {
  value = [
    github_actions_secret.gcp_key_dev.secret_name,
    github_actions_secret.gcp_key_staging.secret_name,
    github_actions_secret.gcp_key_prod.secret_name
  ]
}
