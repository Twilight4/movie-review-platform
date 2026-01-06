# Create SA for GKE cluster
resource "google_service_account" "gke_nodes" {
  account_id   = "${var.prefix}-gke-nodes"
  display_name = "GKE Node Service Account"
  description  = "Service account for GKE nodes in ${var.prefix} environment"
}

# Create container cluster itself
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true
  initial_node_count       = 1

  # Let terraform destroy the cluster
  deletion_protection = false

  # Enable the GCE ingress controller add-on
  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # allocate Pod + Service IP ranges automatically (Autopilot-style IP) via VPC-native routing
  ip_allocation_policy {}

  # Resource labels for tracking and cost management
  resource_labels = {
    component = "gke-cluster"
  }
}

# Create node pool for container cluster using that SA
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    preemptible  = true
    machine_type = var.node_machine_type
    disk_size_gb = var.disk_size_gb # Defaults to 100GB
    disk_type    = var.disk_type    # defaults to pd-balanced

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      component = "gke-node"
    }
  }
}
