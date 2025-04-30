# Docker Networking Tutorial

## Understanding Container Port Isolation

Docker containers use network namespaces to provide complete network isolation. This means each container gets its own:
- Network stack
- Routing table
- Network interfaces
- IP addresses
- Port space

### Key Concepts

1. **Container Internal Ports**
   - Each container has its own port namespace
   - Multiple containers can use the same port internally
   - Example: Both Grafana and OpenSpeedTest can use port 3000 internally

2. **Port Mapping**
   - Format: `HOST_PORT:CONTAINER_PORT`
   - Only needed when accessing container from host machine
   - Example: `3100:3000` maps container's port 3000 to host's port 3100

3. **Docker Networks**
   - Containers in same network can communicate using service names
   - Internal ports are used for container-to-container communication
   - Nginx reverse proxy uses internal container ports

### Our Setup Example

```plaintext
                                        Docker Network (homelab-net)
                                        ┌────────────────────────────────────────┐
                                        │                                        │
Host Machine                           │    ┌─────────────────┐                │
┌─────────────────┐                    │    │   Grafana       │                │
│ Port 3000       │                    │    │   Port 3000     │                │
│ → OpenSpeedTest │                    │    └─────────────────┘                │
│                 │                    │                                        │
│ Port 3100       │                    │    ┌─────────────────┐                │
│ → Grafana       │                    │    │  OpenSpeedTest  │                │
│                 │                    │    │   Port 3000     │                │
└─────────────────┘                    │    └─────────────────┘                │
                                        │                                        │
                                        └────────────────────────────────────────┘
```

### Useful Docker Network Commands

1. List all networks:
   ```bash
   docker network ls
   ```

2. Inspect a network:
   ```bash
   docker network inspect homelab-net
   ```

3. View container network settings:
   ```bash
   docker inspect <container_name> -f '{{json .NetworkSettings.Networks}}'
   ```

4. View container port mappings:
   ```bash
   docker port <container_name>
   ```

5. View container processes and ports:
   ```bash
   docker container ls --format "table {{.Names}}\t{{.Ports}}"
   ```

### Common Networking Patterns

1. **Internal Communication**
   ```nginx
   # Nginx config using internal container port
   proxy_pass http://grafana:3000;
   ```

2. **External Access**
   ```yaml
   # docker-compose.yml port mapping
   ports:
     - "3100:3000"  # Host:Container
   ```

3. **Network Isolation**
   ```yaml
   # docker-compose.yml network definition
   networks:
     - homelab-net
   ```

### Best Practices

1. Only expose ports to host when needed
2. Use internal Docker networks for container communication
3. Use meaningful service names in docker-compose
4. Document port mappings (like in PORTS.md)
5. Use reverse proxy for external access management
