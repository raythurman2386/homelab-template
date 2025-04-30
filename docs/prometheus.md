# Prometheus Monitoring

## Overview
Prometheus is an open-source monitoring and alerting system designed for reliability and scalability. In our homelab, it collects metrics from various services and provides a powerful query language (PromQL) for analyzing system performance.

## Current Configuration
- **Host Port**: 9090
- **Container Port**: 9090
- **Health Check**: `http://localhost:9090/-/healthy`
- **Data Storage**: `/prometheus`
- **Configuration File**: `/etc/prometheus/prometheus.yml`

## Services Being Monitored
- **Prometheus itself** (`localhost:9090`)
- **Node Exporter** (`node-exporter:9100`) - System metrics from the Raspberry Pi
- **cAdvisor** (`cadvisor:8080`) - Container metrics
- **Pi-hole** (`pihole:80`) - DNS and ad-blocking metrics

## Access
- Web UI: http://prometheus.local or http://localhost:9090
- API: http://localhost:9090/api/v1

## Common Use Cases

### 1. Check System Load
```promql
node_load1{job="node_exporter"}
```

### 2. Memory Usage
```promql
node_memory_MemAvailable_bytes{job="node_exporter"} / node_memory_MemTotal_bytes{job="node_exporter"} * 100
```

### 3. Disk Usage
```promql
100 - ((node_filesystem_avail_bytes{job="node_exporter",fstype="ext4"} * 100) / node_filesystem_size_bytes{job="node_exporter",fstype="ext4"})
```

### 4. Container CPU Usage
```promql
sum(rate(container_cpu_usage_seconds_total{name=~".+"}[5m])) by (name)
```

### 5. Pi-hole Blocked Domains
```promql
pihole_domains_blocked{job="pihole"}
```

### 6. Network Traffic
```promql
rate(node_network_receive_bytes_total{device="eth0"}[5m])
rate(node_network_transmit_bytes_total{device="eth0"}[5m])
```

## Optimization Tips for Raspberry Pi

1. **Adjust Scrape Interval**: Current setting is 15s. Consider 30s for less resource usage.
2. **Storage Retention**: Set appropriate `--storage.tsdb.retention.time` (default is 15 days).
3. **Limit Target Metrics**: Use relabeling to filter out unnecessary metrics.
4. **Compression**: Enable TSDB compression with `--storage.tsdb.wal-compression`.

## Maintenance Tasks

### Backup Prometheus Data
```bash
docker cp prometheus:/prometheus /your/backup/path/
```

### Checking Prometheus Health
```bash
wget -qO- http://localhost:9090/-/healthy
```

### Validating Configuration
```bash
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

## Common Issues

### High Memory Usage
- Increase scrape interval
- Decrease retention period
- Filter metrics using relabeling

### Target Connection Failures
- Check if the target service is running
- Verify network connectivity
- Check firewall rules

## References
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [PromQL Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
