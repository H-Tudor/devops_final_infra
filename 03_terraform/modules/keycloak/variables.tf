variable "config" {
  description = "GCP Deployment Configuration"

  type = object({
    project_id = string
    region     = string
  })
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
}

variable "keycloak" {
  description = "Keycloak Configuration"
  type = object({
    image = object({
      name = string
      tag  = string
    })

    instance = object({
      name                  = string
      admin_password_secret = string
      port                  = optional(number, 8080)
    })

    domain = object({
      name = string
      zone = string
    })
  })
}