# Enable required APIs
resource "google_project_service" "cloudresourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  project            = var.gcp_project_id
  disable_on_destroy = false
}

resource "google_project_service" "container" {
  service            = "container.googleapis.com"
  project            = var.gcp_project_id
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  project            = var.gcp_project_id
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  service            = "logging.googleapis.com"
  project            = var.gcp_project_id
  disable_on_destroy = false
}

resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  project            = var.gcp_project_id
  disable_on_destroy = false
}

# Shared VPC Peering for Private Connectivity
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address-${var.environment}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${var.gcp_project_id}/global/networks/fintech-${var.environment}-vpc"

  depends_on = [google_project_service.compute]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "projects/${var.gcp_project_id}/global/networks/fintech-${var.environment}-vpc"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.compute]
}


# Cloud SQL Database Module
module "cloudsql" {
  source = "./modules/cloudsql"

  project_id        = var.gcp_project_id
  region            = var.gcp_region
  environment       = var.environment
  instance_name     = "fintech-${var.environment}-db"
  database_version  = "POSTGRES_15"
  tier              = local.database_config[var.environment].tier
  availability_type = local.database_config[var.environment].availability_type
  enable_backup     = local.database_config[var.environment].backup_enabled

  network_id    = data.google_compute_network.vpc.name
  database_name = "fintech_db"
  username      = "fintech_user"

  labels = local.common_labels

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

# Memorystore Redis Module
module "redis" {
  source = "./modules/redis"

  project_id    = var.gcp_project_id
  region        = var.gcp_region
  environment   = var.environment
  instance_name = "fintech-${var.environment}-redis"
  tier          = local.redis_config[var.environment].tier
  size_gb       = local.redis_config[var.environment].size_gb
  redis_version = "REDIS_7_0"
  network_id    = data.google_compute_network.vpc.name

  labels = local.common_labels

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

# Load Balancer Module

# Phase 4: Monitoring, Security, Logging
module "monitoring" {
  source = "./modules/monitoring"

  project_id  = var.gcp_project_id
  alert_email = "nari.nanda@gmail.com"
}

module "security" {
  source = "./modules/security"

  project_id  = var.gcp_project_id
  db_password = module.cloudsql.database_password
  redis_token = module.redis.auth_token
  api_key     = random_password.api_key.result
}

module "logging" {
  source = "./modules/logging"

  project_id = var.gcp_project_id
}

# Generate API Key
resource "random_password" "api_key" {
  length  = 32
  special = true
}

module "ci_identity" {
  source     = "./modules/ci-identity"
  project_id = var.gcp_project_id
}

data "google_compute_network" "vpc" {
  name    = "fintech-dev-vpc"
  project = var.gcp_project_id
}
