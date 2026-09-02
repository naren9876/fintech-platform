output "secrets_created" {
  value = [
    google_secret_manager_secret.db_password.id,
    google_secret_manager_secret.redis_token.id,
    google_secret_manager_secret.api_key.id
  ]
  description = "Secrets stored in Secret Manager"
}
