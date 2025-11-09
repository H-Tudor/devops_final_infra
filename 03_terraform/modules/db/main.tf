resource "google_sql_database_instance" "this" {
  name                = var.instance.name
  region              = var.config.region
  database_version    = var.instance.type
  deletion_protection = false

  settings {
    tier    = var.instance.tier.name
    edition = var.instance.tier.edition

    ip_configuration {
      authorized_networks {
        name  = "internet"
        value = "0.0.0.0/1"
      }
    }
  }
}

data "google_secret_manager_secret_version" "db_password" {
  secret  = var.database.password_secret
  project = var.config.project_id
}

resource "google_sql_database" "database" {
  name     = var.database.name
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "user" {
  instance = google_sql_database_instance.this.name
  name     = var.database.username
  password = data.google_secret_manager_secret_version.db_password.secret_data
}