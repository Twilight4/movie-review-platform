#!/bin/bash
set -euo pipefail

# --- Required Inputs ---
PROJECT_ID="${PROJECT_ID:-}"
BUCKET_NAME="${BUCKET_NAME:-}"
SA_NAME="${SA_NAME:-terraform}"

if [[ -z "$PROJECT_ID" || -z "$BUCKET_NAME" ]]; then
  echo "[ERROR] Missing required environment variables PROJECT_ID and BUCKET_NAME."
  echo "Usage: PROJECT_ID=my-project BUCKET_NAME=tfstate-12345 ./delete-backend.sh"
  exit 1
fi

SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

log() {
  echo "[INFO] $1"
}

error() {
  echo "[ERROR] $1" >&2
}

trap 'error "Script failed at line $LINENO."' ERR

# ------------------------------------------------------
# DELETE GCS BUCKET
# ------------------------------------------------------

log "Checking if bucket exists: gs://$BUCKET_NAME"
if gcloud storage buckets list --project "$PROJECT_ID" | grep -q "$BUCKET_NAME"; then

  log "Deleting bucket: gs://$BUCKET_NAME (recursive)"
  gcloud storage rm -r "gs://$BUCKET_NAME" || true

  log "Removing bucket (final deletion)"
  gcloud storage buckets delete "gs://$BUCKET_NAME" --quiet
else
  log "Bucket does not exist, skipping deletion."
fi

# ------------------------------------------------------
# DELETE SERVICE ACCOUNT + KEYS
# ------------------------------------------------------

log "Checking if service account exists: $SA_EMAIL"
if gcloud iam service-accounts list --project "$PROJECT_ID" | grep -q "$SA_EMAIL"; then

  # Remove IAM bindings (optional but nice to clean up)
  log "Removing IAM roles for service account"
  ROLES=$(gcloud projects get-iam-policy "$PROJECT_ID" \
    --flatten="bindings[].members" \
    --filter="bindings.members:serviceAccount:$SA_EMAIL" \
    --format="value(bindings.role)")

  for ROLE in $ROLES; do
    log "Removing role $ROLE"
    gcloud projects remove-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:$SA_EMAIL" \
      --role="$ROLE" --quiet || true
  done

  # Delete service account (this auto-deletes its keys)
  log "Deleting service account: $SA_EMAIL"
  gcloud iam service-accounts delete "$SA_EMAIL" --quiet
else
  log "Service account does not exist, skipping deletion."
fi

log "Backend resources removed successfully."

echo ""
echo "Deleted resources:"
echo "  project_id:    $PROJECT_ID"
echo "  bucket_name:   $BUCKET_NAME"
echo "  sa_email:      $SA_EMAIL"
