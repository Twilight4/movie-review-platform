# VPC
resource "google_compute_network" "gke_vpc" {
  name                    = "${var.prefix}-gke-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${var.prefix}-gke-subnet"
  ip_cidr_range = "10.10.0.0/20"
  network       = google_compute_network.gke_vpc.id
  region        = var.region
}

# Firewall rules: allow internal cluster communication
resource "google_compute_firewall" "gke_internal" {
  name    = "${var.prefix}-gke-internal"
  network = google_compute_network.gke_vpc.name

  allows {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.10.0.0/20"]
}
