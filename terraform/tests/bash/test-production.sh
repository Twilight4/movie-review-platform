#!/bin/bash
set -euo pipefail

# Always destroy infrastructure on exit (success or failure)
cleanup() {
  echo "Destroying infrastructure..."
  terraform destroy -auto-approve || true
}
trap cleanup EXIT

# Change directory to terraform production
cd ../../envs/production/

# Create the resources
echo "Initializing Terraform..."
terraform init -input=false
echo "Applying Terraform configuration..."
terraform apply -auto-approve

echo "Fetching health check URL from Terraform outputs..."
HEALTHCHECK_URL=$(terraform output -raw healthcheck_url)

echo "Health check URL: ${HEALTHCHECK_URL}"

# Retry configuration (matches GCE Ingress behavior)
MAX_RETRIES=60
SLEEP_SECONDS=10

echo "Waiting for application to become healthy..."

for ((i=1; i<=MAX_RETRIES; i++)); do
  echo "Attempt ${i}/${MAX_RETRIES}..."

  # Perform HTTP request
  RESPONSE=$(curl -s -m 10 -w "%{http_code}" "${HEALTHCHECK_URL}" || true)

  # Split body and status code
  BODY="${RESPONSE::-3}"
  STATUS="${RESPONSE: -3}"

  if [[ "${STATUS}" == "200" && "${BODY}" == "ok" ]]; then
    echo "Application is healthy ✔"
    exit 0
  fi

  echo "Not ready yet (status=${STATUS}, body='${BODY}')"
  sleep "${SLEEP_SECONDS}"
done

echo "❌ Application failed to become healthy in time"
exit 1
