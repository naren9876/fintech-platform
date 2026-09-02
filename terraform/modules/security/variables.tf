variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}

variable "redis_token" {
  type        = string
  sensitive   = true
  description = "Redis auth token"
}

variable "api_key" {
  type        = string
  sensitive   = true
  description = "API key"
}
