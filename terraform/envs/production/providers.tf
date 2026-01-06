provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  default_labels = {
    environment = "production"
    managed_by  = "terraform"
    project     = "movie-review-platform"
    team        = "devops"
  }
}

