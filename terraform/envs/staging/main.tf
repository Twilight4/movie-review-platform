module "gke" {
  source = "../../modules/gke"

  cluster_name = "staging-gke"
  region       = var.region

  network           = google_compute_network.gke_vpc.self_link
  subnetwork        = google_compute_subnetwork.gke_subnet.self_link
  node_count        = 3
  node_machine_type = "e2-small"
}
