provider "google" {
  project = var.config.project_id
  region  = var.config.deployment.region
  zone    = var.config.deployment.zone
}

terraform {
  backend "gcs" {
    bucket = var.config.state.bucket
    prefix = var.config.state.folder
  }
}

module "keycloak" {
  source = "../../modules/keycloak"

  config = {
    project_id = var.config.project_id
    region     = var.config.deployment.region
  }

  database = var.database
  service  = var.service
}