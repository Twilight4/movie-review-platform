### Step 8: Deploy Pod Disruption Budgets

```bash
# Deploy to staging
helm upgrade staging-movie-api k8s/helm/apps/api-node/api-node-helm-chart \
  -f k8s/helm/apps/api-node/api-node-helm-chart/values-staging.yaml \
  --namespace staging

# Deploy to production
helm upgrade movie-api k8s/helm/apps/api-node/api-node-helm-chart \
  -f k8s/helm/apps/api-node/api-node-helm-chart/values.yaml \
  --namespace production

# Verify PDB is created
kubectl get pdb -n staging
kubectl get pdb -n production
```

### Step 9: Deploy Prometheus Alert Rules

```bash
# Apply alert rules
kubectl apply -f k8s/helm/monitoring/kube-prometheus-stack/prometheus-rules.yaml

# Verify rules are loaded
kubectl get prometheusrule -n monitoring

# Check in Prometheus UI
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Open http://localhost:9090/alerts
```

### Step 10: Update Monitoring Stack

```bash
# Upgrade monitoring with new secret configuration
cd k8s/helm/monitoring
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -f kube-prometheus-stack/values.yaml \
  --namespace monitoring

# Wait for pods to restart
kubectl get pods -n monitoring -w

# Test Grafana access
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# Open http://localhost:3000
# Login with admin / <password-from-secret>
```

## Phase 4: Verification and Testing

### Step 11: Verify All Changes

```bash
# Check terraform state
cd terraform/envs/staging
terraform state list

# Check GKE cluster labels
gcloud container clusters describe stg-gke \
  --region=europe-central2 \
  --format="value(resourceLabels)"

# Check Kubernetes resources
kubectl get pdb -A
kubectl get prometheusrule -n monitoring
kubectl get secret grafana-admin-credentials -n monitoring

# Check pre-commit hooks
pre-commit run --all-files
```

### Step 12: Test Monitoring Alerts

```bash
# Test pod restart alert (optional)
kubectl delete pod -n staging -l app=movie-api

# Watch for alerts in Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Open http://localhost:9090/alerts

# Check AlertManager
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
# Open http://localhost:9093
```

### Step 13: Test Database Protection

```bash
# Try to delete database (should fail)
cd terraform/envs/production
terraform destroy -target=module.firestore

# Expected: Error due to prevent_destroy lifecycle
```

## Phase 5: Documentation and Cleanup

### Step 14: Update Team Documentation

1. Share `SECURITY_AND_SECRETS.md` with team
2. Share `MONITORING_SETUP.md` with operations team
3. Add secret rotation schedule to calendar
4. Update runbooks with new procedures

### Step 15: Configure Alert Notifications (Optional)

Follow `k8s/helm/monitoring/MONITORING_SETUP.md` to:
- Set up Slack notifications
- Configure PagerDuty integration
- Set up email alerts

### Step 16: Merge to Main

Once everything is verified:

```bash
# Create PR
git add .
git commit -m "feat: implement devops infrastructure improvements

- Add terraform state protection
- Remove hardcoded credentials and project IDs
- Enable production database protection
- Add resource labeling for cost tracking
- Implement pre-commit hooks
- Add Pod Disruption Budgets
- Create Prometheus alert rules
- Improve monitoring setup

See DEVOPS_IMPROVEMENTS.org for full details"

git push origin devops-improvements

# Create PR on GitHub
# Get team review
# Merge to main
```

## Rollback Plan

If issues occur:

### Rollback Terraform Changes

```bash
cd terraform/envs/<env>
git checkout main -- main.tf providers.tf
terraform plan
terraform apply
```

### Rollback Kubernetes Changes

```bash
# Remove PDB
kubectl delete pdb -n staging staging-movie-api-pdb
kubectl delete pdb -n production movie-api-pdb

# Remove alert rules
kubectl delete prometheusrule movie-api-alerts -n monitoring

# Rollback Helm releases
helm rollback staging-movie-api -n staging
helm rollback movie-api -n production
```

## Post-Migration Tasks

- [ ] Monitor alerts for false positives
- [ ] Adjust alert thresholds based on actual metrics
- [ ] Schedule secret rotation
- [ ] Set up automated backups verification
- [ ] Plan for OIDC migration (Phase 2)
- [ ] Consider implementing external-secrets-operator
- [ ] Review and optimize resource requests/limits
- [ ] Implement multi-region DR strategy

## Troubleshooting

### Issue: Grafana won't start after secret change

```bash
# Check secret exists
kubectl get secret grafana-admin-credentials -n monitoring

# Check Grafana pods
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana

# Recreate secret if needed
kubectl delete secret grafana-admin-credentials -n monitoring
# Then recreate with correct keys
```

### Issue: Terraform fails with "prevent_destroy"

```bash
# If you really need to destroy (staging only!)
# Edit main.tf and comment out lifecycle block
terraform apply
terraform destroy -target=module.firestore
```

### Issue: Pre-commit hooks failing

```bash
# Skip hooks temporarily (not recommended)
git commit --no-verify

# Or fix issues
terraform fmt -recursive terraform/
pre-commit run --all-files
```

## Support

For issues or questions:
- Check `DEVOPS_IMPROVEMENTS.org` for detailed improvement notes
- Review `SECURITY_AND_SECRETS.md` for security questions
- Check `k8s/helm/monitoring/MONITORING_SETUP.md` for monitoring issues

## Success Criteria

You've successfully migrated when:
- ✅ No terraform state files in git
- ✅ Grafana login works with secret-based password
- ✅ Production database cannot be destroyed via terraform
- ✅ All GCP resources have proper labels
- ✅ Pre-commit hooks run on every commit
- ✅ PDBs prevent full application downtime during node maintenance
- ✅ Prometheus alerts fire correctly
- ✅ Team has access to monitoring documentation
