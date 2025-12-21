module "gke" {
  source = "../../modules/gke"

  project_id   = "movie-review-platform8451"
  cluster_name = "${var.prefix}-gke"
  prefix       = "stg"
  region       = var.region

  network           = google_compute_network.gke_vpc.id
  subnetwork        = google_compute_subnetwork.gke_subnet.id
  node_count        = 1
  node_machine_type = "e2-small"
  disk_type         = "pd-standard"
  disk_size_gb      = 30
}

module "firestore" {
  source     = "../../modules/firestore/"
  project_id = "movie-review-platform8451"

  database_name = "${var.prefix}-firestore"
  prefix        = "stg"
  region        = var.region

  type                    = "FIRESTORE_NATIVE"
  deletion_policy         = "DELETE"
  delete_protection_state = "DELETE_PROTECTION_DISABLED"
}

module "iam" {
  source     = "../../modules/iam/"
  project_id = "movie-review-platform8451"
}

module "workloads" {
  source     = "../../modules/workloads/"
  project_id = "movie-review-platform8451"

  gcp_service_account_name = module.iam.service_account_name
  depends_on               = [module.gke]
}
