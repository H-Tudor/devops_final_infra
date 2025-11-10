data "google_secret_manager_secret_version" "keycloak_admin_password" {
  secret  = var.keycloak.instance.admin_password_secret
  project = var.config.project_id
}

module "db" {
  source = "../db"

  config   = var.config
  database = var.database.config
  instance = var.database.instance
}

module "cloud_run" {
  source = "../cloud_run"

  config = var.config

  domain = {
    name = var.keycloak.domain.name
    zone = var.keycloak.domain.zone
  }

  container = {
    image = "${var.config.region}-docker.pkg.dev/${var.config.project_id}/${var.keycloak.image.name}:${var.keycloak.image.tag}"

    run = {
      args = ["start", "--optimized"]
      port = var.keycloak.instance.port
    }

    env = {
      KC_HEALTH_ENABLED  = true
      KC_METRICS_ENABLED = true
      KC_HTTP_ENABLED    = true
      KC_HOSTNAME_STRICT = false

      KC_PROXY     = "passthrough"
      KC_HTTP_PORT = var.keycloak.instance.port
      KC_HOSTNAME  = "https://${var.keycloak.domain.name}"

      KC_BOOTSTRAP_ADMIN_USERNAME = "admin"
      KC_BOOTSTRAP_ADMIN_PASSWORD = data.google_secret_manager_secret_version.keycloak_admin_password.secret_data

      KC_DB          = "postgres"
      KC_DB_URL      = "jdbc:postgresql://${module.db.ip_address}:5432/${module.db.database}"
      KC_DB_USERNAME = module.db.username
      KC_DB_PASSWORD = module.db.password
    }

    probes = {
      startup = {
        delay      = 20
        timeout    = 10
        period     = 60
        fail       = 11
        http_probe = false
      }

      liveness = {
        delay   = 20
        timeout = 10
        period  = 60
        fail    = 11
      }

      tcp = {
        port = var.keycloak.instance.port
      }

      http = {
        port = var.keycloak.instance.port
        path = "/"
      }
    }
  }

  instance = {
    name = var.keycloak.instance.name
    access = {
      public  = true
      members = ["allUsers"]
    }
    allow_idle_instance = false
    resources = {
      cpu_startup_boost = true
      cpu               = "2"
      ram               = "1Gi"
    }
  }

  depends_on = [module.db]
}