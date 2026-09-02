variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to authenticate"
  type        = string
  default     = "naren9876/fintech-platform"
}
