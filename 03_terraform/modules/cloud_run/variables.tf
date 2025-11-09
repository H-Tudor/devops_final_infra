variable "config" {
  description = "Project Config"
  type = object({
    project_id = string
    region     = string
  })
}


variable "domain" {
  description = "Public Domain Name for instance"
  type = object({
    name = string
    zone = string
  })
  nullable = true
  default  = null
}


variable "container" {
  description = "Container Configuration"
  type = object({
    image = string

    run = object({
      command = optional(list(string), [])
      args    = optional(list(string), [])
      port    = number
    })

    env = optional(map(string), {})

    probes = object({
      startup = object({
        delay      = optional(number, 0)
        timeout    = optional(number, 1)
        period     = optional(number, 3)
        fail       = optional(number, 1)
        http_probe = optional(bool, false)
      })

      liveness = object({
        delay      = optional(number, 0)
        timeout    = optional(number, 1)
        period     = optional(number, 3)
        fail       = optional(number, 1)
        http_probe = optional(bool, true)
      })

      tcp = object({
        port = optional(number, 80)
      })

      http = object({
        port = optional(number, 80)
        path = optional(string, "/")
      })
    })

  })
}

variable "instance" {
  description = "Instance Configuration"
  type = object({
    name = string

    access = object({
      public  = optional(bool, true)
      members = optional(list(string), [])
    })

    resources = object({
      cpu               = optional(string, "1")
      ram               = optional(string, "1Gi")
      cpu_startup_boost = optional(bool, false)
    })

    allow_idle_instance = bool

  })
}