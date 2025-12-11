module "gke" {
  source = "../../modules/gke"

  cluster_name = "${var.prefix}-gke"
  region       = var.region

  network           = google_compute_network.gke_vpc.id
  subnetwork        = google_compute_subnetwork.gke_subnet.id
  node_count        = 2
  node_machine_type = "e2-medium"
}
