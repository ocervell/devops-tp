output "service_url" {
  description = "URL publique du service Cloud Run"
  value       = google_cloud_run_v2_service.helloworld.uri
}

output "service_account_email" {
  description = "Email du compte de service"
  value       = google_service_account.cloudrun_sa.email
}

output "service_name" {
  description = "Nom du service Cloud Run"
  value       = google_cloud_run_v2_service.helloworld.name
}
