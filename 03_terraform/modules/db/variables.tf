variable "config" {
  description = "Project Configuration"
  type = object({
    region     = string
    project_id = string
  })
}

variable "database" {
  description = "Database Configuration"
  type = object({
    name            = string
    username        = string
    password_secret = string
  })
}

variable "instance" {
  description = "Deployment Configuration"
  type = object({
    name = string
    type = string

    tier = object({
      name    = string
      edition = string
    })
  })
}
