output "instance_name" {
  value       = google_redis_instance.cache.name
  description = "Redis instance name"
}

output "host" {
  value       = google_redis_instance.cache.host
  description = "Redis host IP address"
}

output "port" {
  value       = google_redis_instance.cache.port
  description = "Redis port"
}

output "auth_token" {
  value       = random_password.redis_auth_token.result
  sensitive   = true
  description = "Redis AUTH token"
}

output "connection_string" {
  value       = "redis://:${random_password.redis_auth_token.result}@${google_redis_instance.cache.host}:${google_redis_instance.cache.port}"
  sensitive   = true
  description = "Redis connection string"
}

output "region" {
  value       = google_redis_instance.cache.region
  description = "Redis region"
}
