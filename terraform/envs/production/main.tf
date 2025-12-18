module "gke" {
  source = "../../modules/gke"

  cluster_name = "${var.prefix}-gke"
  region       = var.region

  network           = google_compute_network.gke_vpc.id
  subnetwork        = google_compute_subnetwork.gke_subnet.id
  node_count        = 1
  node_machine_type = "e2-small"
  disk_type         = "pd-standard"
  disk_size_gb      = 30
}

module "firestore" {
  source = "../../modules/firestore/"

  project_id = "movie-review-platform8451"
  region     = var.region

  database_name           = "firestore"
  type                    = "FIRESTORE_NATIVE"
  deletion_policy         = "DELETE"
  delete_protection_state = "DELETE_PROTECTION_DISABLED"
}

module "iam" {
  source = "../../modules/iam/"
}

module "workloads" {
  source = "../../modules/workloads/"

  project_id               = "movie-review-platform8451"
  gcp_service_account_name = module.iam.service_account_name
}
