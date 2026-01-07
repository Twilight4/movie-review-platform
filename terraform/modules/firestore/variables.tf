variable "region" {
  description = "GCP region for Firestore database"
  type        = string
}
variable "type" {
  description = "Firestore database type (FIRESTORE_NATIVE or DATASTORE_MODE)"
  type        = string
}
variable "database_name" {
  description = "Name of the Firestore database"
  type        = string
}
variable "deletion_policy" {
  description = "Deletion policy for the database (DELETE or ABANDON)"
  type        = string
}
variable "delete_protection_state" {
  description = "Delete protection state (DELETE_PROTECTION_ENABLED or DELETE_PROTECTION_DISABLED)"
  type        = string
}
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
