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
# APPLY GITOPS APPLICATIONSET
# ==========================================================





# ==========================================================
# VALIDATE THE DEPLOYED APPLICATION
# ==========================================================
echo "Fetching health check URL from Terraform outputs..."
HEALTHCHECK_URL=$(terraform output -raw healthcheck_url)

log_info "Health check URL: ${HEALTHCHECK_URL}"

# Retry configuration for max 10 minutes (matches GCE Ingress behavior)
MAX_RETRIES=60
SLEEP_SECONDS=10

log_info "Waiting for application to become healthy..."

for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Attempt ${i}/${MAX_RETRIES}..."

  # Perform HTTP(S) request with certificate verification
  if RESPONSE=$(curl -s -m 10 -w "%{http_code}" --fail --location "${HEALTHCHECK_URL}" 2>/dev/null || true); then
    BODY="${RESPONSE::-3}"
    STATUS="${RESPONSE: -3}"
    
    if [[ "${STATUS}" == "200" && "${BODY}" == "ok" ]]; then
      log_success "Application is healthy ✔"
      exit 0
    fi

    log_warn "Not ready yet (status=${STATUS}, body='${BODY}')"
  else
    log_warn "Request failed, retrying..."
  fi

  log_warn "Not ready yet (status=${STATUS}, body='${BODY}')"
  sleep "${SLEEP_SECONDS}"
done

log_error "❌ Application failed to become healthy in time"
exit 1
