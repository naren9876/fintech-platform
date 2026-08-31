variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "gke_machine_type" {
  type = string
}

variable "gke_node_count" {
  type = number
}

variable "cloud_sql_tier" {
  type = string
}

variable "redis_memory_size" {
  type = number
}
