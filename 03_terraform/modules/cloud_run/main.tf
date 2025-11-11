data "google_artifact_registry_repository" "this_repo" {
  location      = var.config.region
  repository_id = var.container.image.repository
}

data "google_artifact_registry_docker_image" "this_image" {
  location      = data.google_artifact_registry_repository.this_repo.location
  repository_id = data.google_artifact_registry_repository.this_repo.repository_id
  image_name    = "${var.container.image.name}:${var.container.image.tag}"
}

resource "google_cloud_run_v2_service" "this" {
  name                = var.instance.name
  location            = var.config.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  scaling {
    min_instance_count = var.instance.scaling.min_instance_count
    max_instance_count = var.instance.scaling.max_instance_count
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  template {
    containers {
      image   = data.google_artifact_registry_docker_image.this_image.self_link
      command = length(var.container.run.command) > 0 ? var.container.run.command : null
      args    = length(var.container.run.args) > 0 ? var.container.run.args : null

      ports {
        name           = "http1"
        container_port = var.container.run.port
      }

      dynamic "env" {
        for_each = var.container.env
        content {
          name  = env.key
          value = env.value
        }
      }

      # env {
      #   name = "SECRET_ENV_VAR"
      #   value_source {
      #     secret_key_ref {
      #       secret = google_secret_manager_secret.secret.secret_id
      #       version = "1"
      #     }
      #   }
      # }

      resources {
        cpu_idle          = var.instance.scaling.allow_idle_instance
        startup_cpu_boost = var.instance.scaling.cpu_startup_boost
        limits = {
          "cpu"    = var.instance.resources.cpu
          "memory" = var.instance.resources.ram
        }
      }

      startup_probe {
        initial_delay_seconds = var.container.probes.startup.delay
        timeout_seconds       = var.container.probes.startup.timeout
        period_seconds        = var.container.probes.startup.period
        failure_threshold     = var.container.probes.startup.fail

        dynamic "tcp_socket" {
          for_each = var.container.probes.startup.http_probe == false ? [1] : []
          content {
            port = var.container.probes.tcp.port
          }
        }

        dynamic "http_get" {
          for_each = var.container.probes.startup.http_probe == true ? [1] : []
          content {
            path = var.container.probes.http.path
            port = var.container.probes.http.port
          }
        }
      }

      liveness_probe {
        initial_delay_seconds = var.container.probes.liveness.delay
        timeout_seconds       = var.container.probes.liveness.timeout
        period_seconds        = var.container.probes.liveness.period
        failure_threshold     = var.container.probes.liveness.fail

        http_get {
          path = var.container.probes.http.path
          port = var.container.probes.http.port
        }
      }
    }
  }
}

resource "google_cloud_run_service_iam_binding" "invoker" {
  location = google_cloud_run_v2_service.this.location
  service  = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"

  members = var.instance.access.public ? ["allUsers"] : var.instance.access.members
}

data "google_dns_managed_zone" "main" {
  name = var.domain.zone
}

resource "google_cloud_run_domain_mapping" "default" {
  count = var.domain != null ? 1 : 0

  name     = var.domain.name
  location = google_cloud_run_v2_service.this.location

  metadata {
    namespace = var.config.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.this.name
  }
}

resource "google_dns_record_set" "default" {
  count = var.domain != null ? 1 : 0

  name = "${var.domain.name}."
  type = "CNAME"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.main.name
  rrdatas      = ["ghs.googlehosted.com."]
}