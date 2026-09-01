variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}

variable "cluster_name" {
  type        = string
  description = "GKE Cluster name"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "machine_type" {
  type        = string
  description = "GKE node machine type"
}

variable "node_count" {
  type        = number
  description = "Initial number of nodes"
  default     = 2
}

variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes"
  default     = 2
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes"
  default     = 5
}

variable "preemptible" {
  type        = bool
  description = "Use preemptible nodes"
  default     = false
}

variable "network_name" {
  type        = string
  description = "VPC network name"
}

variable "subnetwork_name" {
  type        = string
  description = "VPC subnetwork name"
}

variable "secondary_ip_range" {
  type = object({
    pods     = string
    services = string
  })
  description = "Secondary IP ranges"
}

variable "enable_workload_identity" {
  type        = bool
  description = "Enable Workload Identity"
  default     = true
}

variable "enable_network_policy" {
  type        = bool
  description = "Enable network policy"
  default     = true
}

variable "enable_shielded_nodes" {
  type        = bool
  description = "Enable Shielded Nodes"
  default     = true
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply"
  default     = {}
}

variable "api_services" {
  type = list(object({
    service = string
  }))
  description = "GCP API services to depend on"
  default     = []
}
