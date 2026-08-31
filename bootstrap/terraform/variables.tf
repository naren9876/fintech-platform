variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "fintech-dev-001"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub Personal Access Token"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository (owner/repo)"
}
