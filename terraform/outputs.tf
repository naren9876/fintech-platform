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
  value       = module.cloudsql.instance_name
  description = "Cloud SQL instance name"
}

output "cloudsql_private_ip" {
  value       = module.cloudsql.private_ip_address
  description = "Cloud SQL private IP"
}

output "database_name" {
  value       = module.cloudsql.database_name
  description = "Database name"
}

output "database_user" {
  value       = module.cloudsql.database_user
  description = "Database username"
}

output "database_password" {
  value       = module.cloudsql.database_password
  sensitive   = true
  description = "Database password"
}

output "connection_string" {
  value       = module.cloudsql.connection_string
  sensitive   = true
  description = "Full connection string"
}

# Redis Outputs
output "redis_host" {
  value       = module.redis.host
  description = "Redis host IP"
}

output "redis_port" {
  value       = module.redis.port
  description = "Redis port"
}

output "redis_auth_token" {
  value       = module.redis.auth_token
  sensitive   = true
  description = "Redis AUTH token"
}

output "redis_connection_string" {
  value       = module.redis.connection_string
  sensitive   = true
  description = "Redis connection string"
}
