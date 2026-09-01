resource "google_redis_instance" "cache" {
  name           = var.instance_name
  memory_size_gb = var.size_gb
  tier           = var.tier
  region         = var.region
  redis_version  = var.redis_version

  authorized_network      = var.network_id
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"

  labels = merge(var.labels, {
    environment = var.environment
  })
}

# Generate auth token/password
resource "random_password" "redis_auth_token" {
  length  = 32
  special = true
}
