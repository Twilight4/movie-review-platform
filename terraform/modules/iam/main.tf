resource "google_service_account" "movie_api" {
  account_id   = "movie-api-gsa"
  display_name = "Movie API Firestore access"
}

resource "google_project_iam_member" "firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.movie_api.email}"
}

resource "google_project_iam_member" "gke_node_lb_admin" {
  project = var.project_id
  role    = "roles/compute.loadBalancerAdmin"
  member  = "serviceAccount:${google_service_account.movie_api.email}"
}

resource "google_project_iam_member" "gke_node_sa" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.movie_api.email}"
}

resource "google_project_iam_member" "gke_node_computer_viewer" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.movie_api.email}"
}

resource "google_project_iam_member" "gke_node_compute_networkadmin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.movie_api.email}"
}

resource "google_project_iam_member" "gke_node_compute_securityadmin" {
  project = var.project_id
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.movie_api.email}"
}
