# Enable Security APIs
resource "google_project_service" "secretmanager" {
  project            = var.project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Secret Manager - Database Password
resource "google_secret_manager_secret" "db_password" {
  secret_id = "fintech-db-password"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

# Secret Manager - Redis Auth Token
resource "google_secret_manager_secret" "redis_token" {
  secret_id = "fintech-redis-token"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "redis_token" {
  secret      = google_secret_manager_secret.redis_token.id
  secret_data = var.redis_token
}

# Secret Manager - API Key
resource "google_secret_manager_secret" "api_key" {
  secret_id = "fintech-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager]
}

resource "google_secret_manager_secret_version" "api_key" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = var.api_key
}
