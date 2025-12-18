output "cluster_name" {
  description = "The name of the GKE cluster."
  value       = google_container_cluster.primary.name
}

output "cluster_id" {
  description = "The full resource ID of the GKE cluster."
  value       = google_container_cluster.primary.id
}

output "location" {
  description = "The region or zone where the cluster is deployed."
  value       = google_container_cluster.primary.location
}

output "endpoint" {
  description = "The IP address of the GKE master endpoint."
  value       = google_container_cluster.primary.endpoint
}

output "node_pool_names" {
  description = "List of names of the created node pools."
  value       = google_container_node_pool.primary_nodes[*].name
}

output "node_pool_ids" {
  description = "List of full resource IDs for the node pools."
  value       = google_container_node_pool.primary_nodes[*].id
}

output "network" {
  description = "The VPC network used by the cluster."
  value       = google_container_cluster.primary.network
}

output "subnetwork" {
  description = "The subnetwork used by the cluster."
  value       = google_container_cluster.primary.subnetwork
}

output "service_account" {
  description = "The service account used by the cluster nodes."
  value       = google_service_account.gke_nodes.email
}
