output "service_name" {
  value = google_cloud_run_v2_service.this.name
}

output "service_url" {
  value = try(google_cloud_run_v2_service.this.uri, "")
}

output "domain_name" {
  value = try(google_cloud_run_domain_mapping.default[0].name, "")
}