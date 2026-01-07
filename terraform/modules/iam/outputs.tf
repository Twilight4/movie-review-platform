output "service_account_name" {
  description = "The name of the movie API service account"
  value       = google_service_account.movie_api.name
}
