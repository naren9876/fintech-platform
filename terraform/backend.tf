terraform {
  backend "gcs" {
    bucket = "fintech-terraform-state-dev"
    prefix = "terraform/state"
  }
}
