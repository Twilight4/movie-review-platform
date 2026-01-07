variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
}
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}
variable "region" {
  description = "GCP region for the GKE cluster"
  type        = string
}
variable "network" {
  description = "VPC network for the GKE cluster"
  type        = string
}
variable "subnetwork" {
  description = "VPC subnetwork for the GKE cluster"
  type        = string
}
variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = string
}
variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
}
variable "disk_size_gb" {
  description = "Disk size in GB for each node"
  type        = string
}
variable "disk_type" {
  description = "Disk type for nodes (pd-standard, pd-balanced, or pd-ssd)"
  type        = string
}
