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
      folder = "devops-final/backend"
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
    realm         = "devops-final-backend"
    client_id     = "fastapi-app"
    client_secret = "keycloak-backend-secret"
  }
}

variable "llm" {
  description = "LLM Related Configurations"
  type = object({
    provider = string
    model    = string
    secret   = string
  })
  default = {
    model    = "gpt-5-nano"
    provider = "openai"
    secret   = "openai-api-key"
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
      name = string
      port = number
    })

    domain = object({
      name = string
      zone = string
    })
  })
  default = {
    image = {
      repository = "devops-final"
      name       = "backend"
      tag        = "latest"
    }

    instance = {
      name = "backend"
      port = 8000
    }

    domain = {
      name = "api.auto-compose.dev"
      zone = "auto-compose-dev"
    }
  }
}