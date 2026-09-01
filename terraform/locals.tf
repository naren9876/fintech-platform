locals {
  common_labels = {
    project     = "fintech-platform"
    environment = var.environment
    managed_by  = "terraform"
  }

  resource_config = {
    dev = {
      gke_machine_type = "e2-medium"
      gke_node_count   = 1
      gke_max_nodes    = 2
    }
    staging = {
      gke_machine_type = "e2-standard-4"
      gke_node_count   = 3
      gke_max_nodes    = 5
    }
    prod = {
      gke_machine_type = "n2-standard-8"
      gke_node_count   = 5
      gke_max_nodes    = 10
    }
  }

  secondary_ip_ranges = {
    dev = {
      pods     = "10.4.0.0/14"
      services = "10.0.0.0/20"
    }
    staging = {
      pods     = "10.8.0.0/14"
      services = "10.16.0.0/20"
    }
    prod = {
      pods     = "10.12.0.0/14"
      services = "10.32.0.0/20"
    }
  }
}
