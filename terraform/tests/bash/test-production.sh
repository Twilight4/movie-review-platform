#!/bin/bash
set -euo pipefail

# Color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }

# ==========================================================
# VALIDATION CHECKS BEFORE CREATION
# ==========================================================
# Always destroy infrastructure on exit (success or failure)
cleanup() {
  echo "Destroying infrastructure..."
  terraform destroy -auto-approve || true
}
trap cleanup EXIT

# Change directory to terraform production
cd ../../envs/production/

# Formatting check
log_info "Checking Terraform formatting..."
terraform fmt -check

log_info "Applying Terraform formatting..."
terraform fmt

# Validate check
log_info "Validating Terraform configuration..."
terraform init -input=false
terraform validate

# Plan check (interactive)
log_info "Generating Terraform plan..."
terraform plan

# ==========================================================
# CREATE INFRASTRUCTURE
# ==========================================================
# Apply
log_info "Applying Terraform configuration..."
terraform apply -auto-approve

# ==========================================================
# APPLY GITOPS APPLICATION VIA ARGOCD
# ==========================================================
# Navigate to Helm manifests directory
log_info "Navigating to Helm manifests directory..."
cd ../../../k8s/helm/apps/api-node/ || { log_error "Failed to navigate to k8s/helm"; exit 1; }

# Render environment manifests for production
log_info "Rendering production manifests..."
if ! go-task argocd:01-render-production; then
    log_error "Rendering production manifests failed. Exiting..."
    exit 1
fi
log-kinfo "Render completed successfully."

# Install / upgrade ArgoCD ApplicationSet (cluster-wide, once)
log-info "Installing/upgrading ArgoCD ApplicationSet..."
if ! go-task argocd:00-install-argocd-applicationset; then
    log_error "ApplicationSet installation failed. Exiting..."
    exit 1
fi
log-info "ApplicationSet applied successfully."

# Apply production env manifest
go-task argocd:02-install-production
log-info "Deploying production manifests..."
if ! go-task argocd:02-install-production; then
    log_error "Deployment of production manifests failed. Exiting..."
    exit 1
fi
log-info "Production manifests deployed successfully."

# ==========================================================
# VALIDATE THE DEPLOYED APPLICATION
# ==========================================================
log_info "Fetching GCP Ingress external IP..."

# Fetch the external IP of the ingress
INGRESS_IP=$(kubectl get ingress my-ingress -n production -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [[ -z "${INGRESS_IP}" ]]; then
    log_error "Failed to fetch Ingress external IP"
    exit 1
fi

# Construct health check URL
HEALTHCHECK_URL="http://${INGRESS_IP}/health"
log_info "Health check URL: ${HEALTHCHECK_URL}"

# Retry configuration for max 10 minutes (matches GCE Ingress behavior)
MAX_RETRIES=60
SLEEP_SECONDS=10

log_info "Waiting for application to become healthy..."
for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Attempt ${i}/${MAX_RETRIES}..."

  STATUS=$(curl -s -o /tmp/response_body.txt -w "%{http_code}" "${HEALTHCHECK_URL}" || echo "000")
  BODY=$(< /tmp/response_body.txt)

  if [[ "${STATUS}" == "200" && "${BODY}" == "ok" ]]; then
      log_success "Application is healthy ✔"
      exit 0
  fi

  log_warn "Not ready yet (status=${STATUS}, body='${BODY}')"
  sleep "${SLEEP_SECONDS}"
done

log_error "❌ Application failed to become healthy in time"
exit 1
