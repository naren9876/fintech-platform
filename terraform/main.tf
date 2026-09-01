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

# GKE Cluster Module
module "gke" {
  source = "./modules/gke"

  project_id   = var.gcp_project_id
  region       = var.gcp_region
  cluster_name = "fintech-${var.environment}"
  environment  = var.environment

  machine_type   = local.resource_config[var.environment].gke_machine_type
  node_count     = local.resource_config[var.environment].gke_node_count
  min_node_count = local.resource_config[var.environment].gke_node_count
  max_node_count = local.resource_config[var.environment].gke_max_nodes

  preemptible = var.environment == "dev" ? true : false

  network_name    = "fintech-${var.environment}-vpc"
  subnetwork_name = "fintech-${var.environment}-subnet"

  secondary_ip_range = {
    pods     = local.secondary_ip_ranges[var.environment].pods
    services = local.secondary_ip_ranges[var.environment].services
  }

  enable_workload_identity = true
  enable_network_policy    = true
  enable_shielded_nodes    = true

  labels = local.common_labels

  depends_on = [
    google_project_service.cloudresourcemanager,
    google_project_service.container,
    google_project_service.compute,
    google_project_service.logging,
    google_project_service.monitoring
  ]
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

  network_id    = module.gke.network_name
  database_name = "fintech_db"
  username      = "fintech_user"

  labels = local.common_labels

  depends_on = [
    module.gke,
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
  network_id    = module.gke.network_name

  labels = local.common_labels

  depends_on = [
    module.gke,
    google_service_networking_connection.private_vpc_connection
  ]
}
