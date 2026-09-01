output "instance_name" {
  value       = google_sql_database_instance.primary.name
  description = "Cloud SQL instance name"
}

output "instance_connection_name" {
  value       = google_sql_database_instance.primary.connection_name
  description = "Connection name for Cloud SQL Proxy"
}

output "private_ip_address" {
  value       = google_sql_database_instance.primary.private_ip_address
  description = "Private IP address of Cloud SQL instance"
}

output "database_name" {
  value       = google_sql_database.database.name
  description = "Database name"
}

output "database_user" {
  value       = google_sql_user.database_user.name
  description = "Database username"
}

output "database_password" {
  value       = random_password.db_password.result
  sensitive   = true
  description = "Database password (sensitive)"
}

output "connection_string" {
  value       = "postgresql://${google_sql_user.database_user.name}:${random_password.db_password.result}@${google_sql_database_instance.primary.private_ip_address}:5432/${google_sql_database.database.name}"
  sensitive   = true
  description = "Full connection string"
}
