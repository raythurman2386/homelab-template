# Docker Troubleshooting Guide

## 1. Checking Logs

- View container logs:
  ```bash
  docker logs -f <container_name>
  ```
- View Compose service logs:
  ```bash
  docker compose logs -f <service_name>
  ```

## 2. Inspecting Containers

- Inspect container details:
  ```bash
  docker inspect <container_name>
  ```
- Inspect network settings:
  ```bash
  docker network inspect <network_name>
  ```

## 3. Port & Network Issues

- List running containers and ports:
  ```bash
  docker ps --format "table {{.Names}}\t{{.Ports}}"
  ```
- Check if service is listening inside container:
  ```bash
  docker exec <container_name> netstat -tulpn
  ```

## 4. Volume & File Permission Problems

- Verify volume mounts:
  ```bash
  docker inspect <container_name> -f '{{.Mounts}}'
  ```
- Fix permissions inside container:
  ```bash
  docker exec <container_name> chown -R user:group /path
  ```

## 5. Build & Image Errors

- Rebuild without cache:
  ```bash
  docker build --no-cache -t <image> .
  ```
- Remove dangling images:
  ```bash
  docker image prune -f
  ```

## 6. Cleaning Up

- Remove stopped containers:
  ```bash
  docker container prune -f
  ```
- Remove unused volumes:
  ```bash
  docker volume prune -f
  ```
- Remove unused networks:
  ```bash
  docker network prune -f
  ```

## 7. Common Tips

- Always check logs first.
- Use `--help` to explore commands.
- Keep Compose files DRY and version-controlled.
