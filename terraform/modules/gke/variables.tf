variable "cluster_name" {
  type = string
}
variable "region" {
  type = string
}
variable "network" {
  type = string
}
variable "subnetwork" {
  type = string
}
variable "node_count" {
  default = 1
}
variable "node_machine_type" {
  default = "e2-small"
}
