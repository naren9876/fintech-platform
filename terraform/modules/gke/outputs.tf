output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE cluster name"
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE cluster endpoint"
  sensitive   = true
}

output "region" {
  value       = google_container_cluster.primary.location
  description = "GKE cluster region"
}

output "network_name" {
  value       = google_compute_network.vpc.name
  description = "VPC network name"
}

output "subnet_name" {
  value       = google_compute_subnetwork.subnet.name
  description = "Subnet name"
}
