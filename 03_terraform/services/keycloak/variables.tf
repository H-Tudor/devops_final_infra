variable "config" {
  description = "GCP Deployment Configuration"

  type = object({
    project_id = string
    deployment = object({
      region = string
      zone   = string
    })
    state = object({
      bucket = string
      folder = string
    })
  })

  default = {
    project_id = "effective-relic-473715-j8"
    deployment = {
      region = "us-central1"
      zone   = "us-central1-a"
    }
    state = {
      bucket = "tfstate-473715"
      folder = "devops-final/keycloak"
    }
  }
}

variable "database" {
  description = "CloudSQL Database Configuration"

  type = object({
    config = object({
      name            = string
      username        = string
      password_secret = string
    })
    instance = object({
      name = string
      type = string

      region     = string
      project_id = string

      tier = object({
        name    = string
        edition = string
      })
    })
  })

  default = {
    config = {
      name            = "keycloak"
      username        = "keycloak"
      password_secret = "keycloak-db-password"
    }
    instance = {
      name       = "keycloak"
      type       = "POSTGRES_16"
      region     = "us-central1"
      project_id = "effective-relic-473715-j8"
      tier = {
        name    = "db-f1-micro"
        edition = "ENTERPRISE"
      }
    }
  }
}

variable "service" {
  description = "Keycloak Configuration"
  type = object({
    image = object({
      repository = string
      name       = string
      tag        = string
    })

    instance = object({
      name                  = string
      admin_password_secret = string
    })

    domain = object({
      name = string
      zone = string
    })
  })
  default = {
    image = {
      repository = "devops-final"
      name       = "keycloak"
      tag        = "26.3.2.1"
    }

    instance = {
      name                  = "keycloak"
      admin_password_secret = "keycloak-admin-password"
    }

    domain = {
      name = "keycloak.auto-compose.dev"
      zone = "auto-compose-dev"
    }
  }
}