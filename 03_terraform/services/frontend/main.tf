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

# ------------------------ Instance Dependencies --------------------------------- #

data "google_cloud_run_v2_service" "keycloak_instance" {
  name     = var.keycloak.name
  location = var.config.deployment.region
}

data "google_cloud_run_v2_service" "backend_instance" {
  name     = var.backend.name
  location = var.config.deployment.region
}

# ------------------------- Secret Dependencies ----------------------------------- #

data "google_secret_manager_secret_version" "frontend_cookie_secret" {
  secret  = var.service.instance.cookie_secret
  project = var.config.project_id
}

data "google_secret_manager_secret_version" "keycloak_frontend_secret" {
  secret  = var.keycloak.client_secret
  project = var.config.project_id
}

data "google_secret_manager_secret_version" "keycloak_backend_secret" {
  secret  = var.backend.auth.client_secret
  project = var.config.project_id
}

data "google_secret_manager_secret_version" "keycloak_backend_password" {
  secret  = var.backend.auth.user_secret
  project = var.config.project_id
}


module "cloud_run" {
  source = "../../modules/cloud_run"
  config = {
    project_id = var.config.project_id
    region     = var.config.deployment.region
  }

  domain = {
    name = var.service.domain.name
    zone = var.service.domain.zone
  }

  container = {
    image = var.service.image

    run = {
      port = var.service.instance.port
    }

    env = {
      AUTH_REDIRECT_URI  = "https://${var.service.domain.name}/oauth2callback"
      AUTH_COOKIE_SECRET = data.google_secret_manager_secret_version.frontend_cookie_secret.secret_data

      AUTH_KEYCLOAK_CLIENT_ID            = var.keycloak.client_id
      AUTH_KEYCLOAK_CLIENT_SECRET        = data.google_secret_manager_secret_version.keycloak_frontend_secret.secret_data
      AUTH_KEYCLOAK_SERVER_METADATA_URL  = "${var.keycloak.domain}/realms/${var.keycloak.realm}/.well-known/openid-configuration"
      AUTH_KEYCLOAK_CLIENT_KWARGS_PROMPT = "login"

      BACKEND_HOST    = var.backend.domain
      BACKEND_VERSION = "vNext"

      BACKEND_AUTH_HOST          = var.keycloak.domain
      BACKEND_AUTH_AUX_HOST      = var.keycloak.domain
      BACKEND_AUTH_REALM         = var.backend.auth.realm
      BACKEND_AUTH_USERNAME      = var.backend.auth.user_name
      BACKEND_AUTH_PASSWORD      = data.google_secret_manager_secret_version.keycloak_backend_password.secret_data
      BACKEND_AUTH_CLIENT_ID     = var.backend.auth.client_id
      BACKEND_AUTH_CLIENT_SECRET = data.google_secret_manager_secret_version.keycloak_backend_secret.secret_data
    }

    probes = {
      startup = {
        delay      = 10
        fail       = 3
        period     = 5
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
        port = var.service.instance.port
      }

      http = {
        port = var.service.instance.port
        path = "/_stcore/health"
      }
    }
  }

  instance = {
    name                = var.service.instance.name
    allow_idle_instance = false
    access = {
      public  = true
      members = ["allUsers"]
    }
    resources = {}
  }

  depends_on = [
    data.google_cloud_run_v2_service.keycloak_instance,
    data.google_cloud_run_v2_service.backend_instance
  ]
}