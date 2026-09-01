output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "kubernetes_cluster_host" {
  value     = "https://${google_container_cluster.primary.endpoint}"
  sensitive = true
}

output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}

output "network_name" {
  value = google_compute_network.private_network.name
}

output "subnet_name" {
  value = google_compute_subnetwork.private_subnet.name
}

output "service_account_email" {
  value = google_service_account.kubernetes_nodes.email
}

output "get_cluster_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}"
}
