# Monitoring Setup Guide

## Overview

This monitoring stack includes:
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notification
- **Grafana Alloy**: Application metrics collection

## Initial Setup

### 1. Create Grafana Admin Secret

**CRITICAL**: Do not use default passwords in production!

```bash
# Generate a secure password
GRAFANA_PASSWORD=$(openssl rand -base64 32)

# Create the secret in the monitoring namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic grafana-admin-credentials \
  --from-literal=admin-user=admin \
  --from-literal=admin-password="${GRAFANA_PASSWORD}" \
  -n monitoring

# Save the password securely (e.g., in a password manager)
echo "Grafana admin password: ${GRAFANA_PASSWORD}"
```

### 2. Install the Monitoring Stack

```bash
cd k8s/helm/monitoring
task install-monitoring
```

### 3. Deploy Prometheus Alert Rules

```bash
kubectl apply -f kube-prometheus-stack/prometheus-rules.yaml
```

## Accessing Services

### Grafana

**Port-forward to access locally:**
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

Then open: http://localhost:3000
- Username: `admin`
- Password: (from the secret created above)

### Prometheus

**Port-forward:**
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

Then open: http://localhost:9090

### AlertManager

**Port-forward:**
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
```

Then open: http://localhost:9093

## Alert Configuration

### Available Alerts

The following alerts are configured in `prometheus-rules.yaml`:

#### Movie API Alerts
- **HighErrorRate**: Triggers when error rate > 5% for 5 minutes
- **PodRestartLoop**: Triggers when pods restart frequently
- **HighCPUUsage**: Triggers when CPU usage > 80% of limit
- **HighMemoryUsage**: Triggers when memory usage > 90% of limit
- **PodNotReady**: Triggers when pods are not in Running state
- **DeploymentReplicaMismatch**: Triggers when deployment replicas don't match

#### Firestore Alerts
- **FirestoreHighLatency**: Triggers when 95th percentile latency > 1s

#### Kubernetes System Alerts
- **NodeNotReady**: Triggers when nodes are not ready
- **PersistentVolumeFillingUp**: Triggers when PV has < 10% space

### Configuring Alert Notifications

To receive alerts, configure AlertManager receivers. Example for Slack:

```yaml
# Add to values.yaml under alertmanager.config
alertmanager:
  config:
    global:
      slack_api_url: '<SLACK_WEBHOOK_URL>'
    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'slack-notifications'
    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - channel: '#alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

## Grafana Dashboards

### Recommended Dashboards to Import

1. **Kubernetes Cluster Monitoring** (ID: 315)
2. **Node Exporter Full** (ID: 1860)
3. **Kubernetes Pod Resources** (ID: 6417)

### Importing Dashboards

1. Go to Grafana → Dashboards → Import
2. Enter dashboard ID
3. Select Prometheus data source
4. Click Import

## Metrics Retention

- **Prometheus retention**: 7 days (configured in values.yaml)
- **Grafana data**: Persisted to 3Gi PVC

To modify retention:
```yaml
# In values.yaml
prometheus:
  prometheusSpec:
    retention: 30d  # Change to 30 days
```

## Troubleshooting

### Grafana Not Starting

Check if secret exists:
```bash
kubectl get secret grafana-admin-credentials -n monitoring
```

Check Grafana logs:
```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana
```

### Alerts Not Firing

1. Check if PrometheusRule is loaded:
```bash
kubectl get prometheusrule -n monitoring
```

2. Check Prometheus config:
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
# Open http://localhost:9090/config
```

3. Check alert status:
```bash
# Open http://localhost:9090/alerts
```

### Missing Metrics

1. Check ServiceMonitor configuration:
```bash
kubectl get servicemonitor -n monitoring
```

2. Check target status in Prometheus:
```bash
# Open http://localhost:9090/targets
```

## Security Best Practices

1. ✅ Use Kubernetes secrets for credentials
2. ✅ Rotate Grafana admin password regularly
3. ✅ Use RBAC to restrict access to monitoring namespace
4. ⚠️ Consider enabling TLS for Grafana ingress
5. ⚠️ Consider network policies to restrict access

## Cost Optimization

- Monitor storage usage: `kubectl get pvc -n monitoring`
- Adjust retention based on requirements
- Use lower scrape intervals for non-critical metrics
- Consider using Grafana Loki for log aggregation (cheaper than Elasticsearch)

## Next Steps

1. Configure alert notifications (Slack, PagerDuty, email)
2. Create custom dashboards for application metrics
3. Set up SLO/SLI tracking
4. Implement log aggregation with Loki
5. Add distributed tracing with Jaeger/Tempo
