locals {
  common_labels = {
    Project     = "fintech"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  is_prod = var.environment == "prod"

  resource_config = {
    dev = {
      machine_type = "e2-medium"
      node_count   = 2
      db_tier      = "db-f1-micro"
      redis_size   = 1
    }
    staging = {
      machine_type = "e2-standard-4"
      node_count   = 3
      db_tier      = "db-custom-2-8192"
      redis_size   = 2
    }
    prod = {
      machine_type = "n2-standard-8"
      node_count   = 5
      db_tier      = "db-custom-4-16384"
      redis_size   = 10
    }
  }

  current = local.resource_config[var.environment]
}
