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
      folder = "devops-final/frontend"
    }
  }
}

variable "keycloak" {
  description = "Keycloak Deployment Information"
  type = object({
    name          = string
    domain        = string
    realm         = string
    client_id     = string
    client_secret = string
  })
  default = {
    name          = "keycloak"
    domain        = "https://keycloak.auto-compose.dev"
    realm         = "devops-final-frontend"
    client_id     = "streamlit-app"
    client_secret = "keycloak-frontend-secret"
  }
}

variable "backend" {
  description = "Backend API configuration"
  type = object({
    name   = string
    domain = string
    auth = object({
      realm         = string
      client_id     = string
      client_secret = string
      user_name     = string
      user_secret   = string
    })

  })
  default = {
    name   = "backend"
    domain = "https://api.auto-compose.dev"
    auth = {
      realm         = "devops-final-backend"
      client_id     = "fastapi-app"
      client_secret = "keycloak-backend-secret"
      user_name     = "streamlit-app"
      user_secret   = "keycloak-frontend-password"
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
      name          = string
      port          = number
      cookie_secret = string
    })

    domain = object({
      name = string
      zone = string
    })
  })
  default = {
    image = {
      repository = "devops-final"
      name       = "frontend"
      tag        = "latest"
    }

    instance = {
      name          = "frontend"
      port          = 8501
      cookie_secret = "frontend-cookie-password"
    }

    domain = {
      name = "app.auto-compose.dev"
      zone = "auto-compose-dev"
    }
  }
}