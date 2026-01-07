variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "gcp_service_account_name" {
  description = "GCP service account name for workload identity binding"
  type        = string
}
