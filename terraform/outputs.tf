output "environment" {
  value = var.environment
}

output "project_id" {
  value = var.gcp_project_id
}

output "region" {
  value = var.gcp_region
}

# Cloud SQL Outputs
output "cloudsql_instance_name" {
  value = module.cloudsql.instance_name
}

output "cloudsql_private_ip" {
  value = module.cloudsql.private_ip_address
}

output "database_name" {
  value = module.cloudsql.database_name
}

output "database_user" {
  value = module.cloudsql.database_user
}

output "database_password" {
  value     = module.cloudsql.database_password
  sensitive = true
}

output "connection_string" {
  value     = module.cloudsql.connection_string
  sensitive = true
}

# Redis Outputs
output "redis_host" {
  value = module.redis.host
}

output "redis_port" {
  value = module.redis.port
}

output "redis_auth_token" {
  value     = module.redis.auth_token
  sensitive = true
}

output "redis_connection_string" {
  value     = module.redis.connection_string
  sensitive = true
}

# Phase 4 Outputs
output "monitoring_dashboard" {
  value       = module.monitoring.dashboard_url
  description = "Cloud Monitoring dashboards"
}

output "logging_console" {
  value       = module.logging.logs_url
  description = "Cloud Logging console"
}

output "api_key" {
  value       = random_password.api_key.result
  sensitive   = true
  description = "Generated API key"
}
