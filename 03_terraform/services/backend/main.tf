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

data "google_cloud_run_v2_service" "keycloak_instance" {
  name     = var.keycloak.name
  location = var.config.deployment.region
}

data "google_secret_manager_secret_version" "keycloak_secret" {
  secret  = var.keycloak.client_secret
  project = var.config.project_id
}

data "google_secret_manager_secret_version" "llm_secret" {
  secret  = var.llm.secret
  project = var.config.project_id
}

module "cloud_run" {
  source = "../../modules/cloud_run"
  config = {
    project_id = var.config.project_id
    region     = var.config.deployment.region
  }

  domain = {
    name = var.backend.domain.name
    zone = var.backend.domain.zone
  }

  container = {
    image = "${var.config.deployment.region}-docker.pkg.dev/${var.config.project_id}/${var.backend.image.name}:${var.backend.image.tag}"

    run = {
      args = ["start", "--optimized"]
      port = var.backend.instance.port
    }

    env = {
      APP_NAME    = "Devops Final"
      APP_VERSION = "vNext"
      APP_PORT    = var.backend.instance.port
      DEBUG       = true

      LLM_MODEL    = var.llm.model
      LLM_PROVIDER = var.llm.provider
      LLM_SECRET   = data.google_secret_manager_secret_version.llm_secret.secret_data

      KEYCLOAK_URL           = var.keycloak.domain
      KEYCLOAK_REALM         = var.keycloak.realm
      KEYCLOAK_CLIENT_ID     = var.keycloak.client_id
      KEYCLOAK_CLIENT_SECRET = data.google_secret_manager_secret_version.keycloak_secret.secret_data
    }

    probes = {
      startup = {
        delay      = 5
        fail       = 3
        period     = 3
        timeout    = 3
        http_probe = true
      }

      liveness = {
        delay   = 3
        fail    = 3
        period  = 60
        timeout = 5
      }

      tcp = {
        port = var.backend.instance.port
      }

      http = {
        port = var.backend.instance.port
        path = "/version"
      }
    }
  }

  instance = {
    name                = var.backend.instance.name
    allow_idle_instance = false
    access = {
      public  = true
      members = ["allUsers"]
    }
    resources = {}
  }

  depends_on = [data.google_cloud_run_v2_service.keycloak_instance]
}