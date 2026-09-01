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
  description = "Cloud SQL instance name"
}

variable "database_version" {
  type        = string
  description = "PostgreSQL version"
  default     = "POSTGRES_15"
}

variable "tier" {
  type        = string
  description = "Machine tier (db-f1-micro, db-custom-2-8192, etc)"
  default     = "db-f1-micro"
}

variable "availability_type" {
  type        = string
  description = "Availability type (REGIONAL for HA, ZONAL for dev)"
  default     = "ZONAL"
}

variable "enable_backup" {
  type        = bool
  description = "Enable automated backups"
  default     = true
}

variable "backup_location" {
  type        = string
  description = "Backup location (region or multi-region)"
  default     = "us"
}

variable "network_id" {
  type        = string
  description = "VPC network ID for private IP"
}

variable "database_name" {
  type        = string
  description = "Database name"
  default     = "fintech_db"
}

variable "username" {
  type        = string
  description = "Database username"
  default     = "fintech_user"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply"
  default     = {}
}
