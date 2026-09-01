resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = false

  network    = google_compute_network.private_network.name
  subnetwork = google_compute_subnetwork.private_subnet.name

  deletion_protection = false

  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      minimum        = 1
      maximum        = 64
    }
    resource_limits {
      resource_type = "memory"
      minimum        = 1
      maximum        = 256
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  network_policy {
    enabled = var.enable_network_policy
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  enable_shielded_nodes = var.enable_shielded_nodes

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  node_pool {
    name       = "default-pool"
    node_count = var.node_count

    autoscaling {
      min_node_count = var.min_node_count
      max_node_count = var.max_node_count
    }

    management {
      auto_repair  = true
      auto_upgrade = true
    }

    node_config {
      preemptible  = var.preemptible
      machine_type = var.machine_type
      disk_size_gb = 12
      disk_type    = "pd-standard"

      service_account = google_service_account.kubernetes_nodes.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]

      workload_metadata_config {
        mode = "GKE_METADATA"
      }

      shielded_instance_config {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }

      labels = merge(var.labels, {
        environment = var.environment
      })

      tags = [var.environment, var.cluster_name, "gke-node"]

      metadata = {
        disable-legacy-endpoints = "true"
      }
    }
  }

  resource_labels = merge(var.labels, {
    environment = var.environment
    managed_by  = "terraform"
  })

  depends_on = [google_compute_subnetwork.private_subnet]
}

resource "google_service_account" "kubernetes_nodes" {
  account_id   = "gke-nodes-${var.environment}"
  display_name = "GKE Nodes - ${var.environment}"
  project      = var.project_id
}

resource "google_project_iam_member" "kubernetes_nodes_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.kubernetes_nodes.email}"
}

resource "google_project_iam_member" "kubernetes_nodes_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.kubernetes_nodes.email}"
}

resource "google_project_iam_member" "kubernetes_nodes_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.kubernetes_nodes.email}"
}

resource "google_compute_network" "private_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = var.subnetwork_name
  ip_cidr_range = "10.128.0.0/20"
  region        = var.region
  network       = google_compute_network.private_network.id
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
