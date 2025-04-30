# Grafana Dashboard System

## Overview
Grafana is an open-source visualization and analytics platform that integrates with Prometheus to create beautiful, interactive dashboards for your homelab metrics. It transforms the raw data from Prometheus into actionable insights about your Raspberry Pi and services.

## Current Configuration
- **Host Port**: 3100
- **Container Port**: 3000
- **Health Check**: `http://localhost:3000/api/health`
- **Data Storage**: `/var/lib/grafana` (persistent volume)
- **Admin Password**: `H0meL@b2025Temp` (should be changed for security)
- **Access URL**: http://grafana.local or http://localhost:3100

## Integration with Prometheus
Grafana uses Prometheus as its data source to visualize metrics from:
- System resources (CPU, memory, disk, network)
- Docker containers
- Pi-hole statistics
- Node Exporter metrics
- Any other service monitored by Prometheus

## Dashboards for Your Homelab Services

### 1. Raspberry Pi System Dashboard
Visualize:
- CPU usage and temperature
- Memory usage
- Disk space
- Network traffic
- System load

### 2. Pi-hole Dashboard
Track:
- DNS queries (total, blocked, cached)
- Top clients
- Top domains
- Query types
- Blocked domains over time

### 3. Docker Dashboard
Monitor:
- Container CPU usage
- Container memory usage
- Container network I/O
- Container disk I/O
- Running vs stopped containers

### 4. Nginx Dashboard
Analyze:
- Request rate
- Status codes
- Response times
- Connection stats
- Traffic by virtual host (for your different services)

### 5. Custom Service Dashboards
Create specific panels for:
- Markitdown service health and usage
- Speedtest results over time
- Dashboard service metrics

## Setup Instructions

### Adding the Prometheus Data Source
1. Navigate to Configuration > Data Sources
2. Click "Add data source"
3. Select "Prometheus"
4. Set URL to `http://prometheus:9090`
5. Click "Save & Test"

### Importing Pre-built Dashboards
1. Click "+" > Import
2. Enter dashboard ID:
   - 1860 (Node Exporter Full)
   - 193 (Docker containers)
   - 10176 (Pi-hole)
   - 12708 (Nginx)
3. Select your Prometheus data source
4. Click "Import"

## Optimizing Grafana for Raspberry Pi

1. **Database Settings**:
   ```ini
   # Add to grafana.ini
   [database]
   cache_mode = "shared"
   ```

2. **Reduce Dashboard Complexity**:
   - Use fewer panels per dashboard
   - Increase refresh intervals (30s or higher)
   - Limit time range defaults to 6h or less

3. **Disable Unused Features**:
   ```ini
   # Add to grafana.ini
   [feature_toggles]
   publicDashboards = false
   reportingV2 = false
   ```

## Maintenance Tasks

### Backing Up Grafana
```bash
docker cp grafana:/var/lib/grafana /your/backup/path/
```

### Resetting Admin Password
```bash
docker exec -it grafana grafana-cli admin reset-admin-password NewSecurePassword
```

### Checking Grafana Health
```bash
curl -I http://localhost:3100/api/health
```

## Alert Setup (Optional)
Grafana can send alerts based on metric thresholds:

1. Navigate to Alerting > Contact points
2. Add a new contact point (email, Slack, etc.)
3. Create alert rules in your dashboards
4. Set conditions and assign to the contact point

## References
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Grafana Dashboard Library](https://grafana.com/grafana/dashboards/)
- [Grafana Community](https://community.grafana.com/)
