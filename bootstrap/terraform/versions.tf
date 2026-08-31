terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "github" {
  token = var.github_token
  owner = split("/", var.github_repository)[0]
}

data "google_client_config" "default" {}
