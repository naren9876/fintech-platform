# Cloud SQL Instance
resource "google_sql_database_instance" "primary" {
  name                = var.instance_name
  database_version    = var.database_version
  region              = var.region
  deletion_protection = false

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = "PD_SSD"
    disk_size         = var.environment == "dev" ? 10 : 50

    backup_configuration {
      enabled                        = var.enable_backup
      start_time                     = "03:00"
      location                       = var.backup_location
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 30
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/${var.network_id}"
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    insights_config {
      query_insights_enabled  = var.environment != "dev"
      query_string_length     = 1024
      record_application_tags = false
    }
  }
}

# Database
resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.primary.name
}

# Database User
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "google_sql_user" "database_user" {
  name     = var.username
  instance = google_sql_database_instance.primary.name
  password = random_password.db_password.result
}
