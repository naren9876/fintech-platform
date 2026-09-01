variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
  default     = "us-central1"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "instance_name" {
  type        = string
  description = "Redis instance name"
}

variable "tier" {
  type        = string
  description = "Service tier (BASIC or STANDARD)"
  default     = "BASIC"
}

variable "size_gb" {
  type        = number
  description = "Redis instance size in GB"
  default     = 1
}

variable "redis_version" {
  type        = string
  description = "Redis version"
  default     = "REDIS_7_0"
}

variable "network_id" {
  type        = string
  description = "VPC network ID for private IP"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply"
  default     = {}
}
