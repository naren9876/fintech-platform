# GKE Cluster Module
module "gke" {
  source = "./modules/gke"

  project_id   = var.gcp_project_id
  region       = var.gcp_region
  cluster_name = "fintech-${var.environment}"
  environment  = var.environment

  # Use local values for resource sizing per environment
  machine_type   = local.resource_config[var.environment].gke_machine_type
  node_count     = local.resource_config[var.environment].gke_node_count
  min_node_count = local.resource_config[var.environment].gke_node_count
  max_node_count = local.resource_config[var.environment].gke_max_nodes

  # Only use preemptible nodes in dev (to save costs)
  preemptible = var.environment == "dev" ? true : false

  # Network configuration
  network_name    = "fintech-${var.environment}-vpc"
  subnetwork_name = "fintech-${var.environment}-subnet"

  # Secondary IP ranges for VPC-native cluster
  secondary_ip_range = {
    pods     = local.secondary_ip_ranges[var.environment].pods
    services = local.secondary_ip_ranges[var.environment].services
  }

  # Security features
  enable_workload_identity = true
  enable_network_policy    = true
  enable_shielded_nodes    = true

  # Labels
  labels = local.common_labels
}
