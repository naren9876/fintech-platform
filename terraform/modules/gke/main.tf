resource "google_container_cluster" "primary" {
  name            = var.cluster_name
  location        = var.region
  project         = var.project_id
  node_version    = "1.35"
  
  deletion_protection = false
  network            = var.network_name
  subnetwork         = var.subnetwork_name

  remove_default_node_pool = false

  node_pool {
    name               = "${var.cluster_name}-default-pool"
    initial_node_count = var.node_count

    node_config {
      preemptible  = var.preemptible
      machine_type = var.machine_type
      disk_type    = "pd-standard"
      disk_size_gb = 30

      workload_metadata_config {
        mode = "GKE_METADATA"
      }

      labels = var.labels
    }

    autoscaling {
      min_node_count = var.min_node_count
      max_node_count = var.max_node_count
    }

    management {
      auto_repair  = true
      auto_upgrade = true
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  network_policy {
    enabled = var.enable_network_policy
  }

  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.subnet
  ]
}

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnetwork_name
  ip_cidr_range = "10.0.0.0/20"
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.secondary_ip_range.pods
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.secondary_ip_range.services
  }
}
