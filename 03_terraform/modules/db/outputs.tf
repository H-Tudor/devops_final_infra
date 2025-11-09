output "ip_address" {
  value = google_sql_database_instance.this.ip_address.0.ip_address
}

output "database" {
  value = google_sql_database.database.name
}

output "username" {
  value = google_sql_user.user.name
}

output "password" {
  value     = google_sql_user.user.password
  sensitive = true
}