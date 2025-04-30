# Docker Security Best Practices

Keeping your Docker deployments secure is critical. This guide covers common practices and tools.

## 1. Use Minimal Base Images
- Prefer `alpine`, `scratch`, or slim variants.
- Remove unused packages to reduce attack surface.

## 2. Principle of Least Privilege
- Avoid running as root: add a non-root user in your Dockerfile:
  ```dockerfile
  RUN useradd -m appuser && chown -R appuser /app
  USER appuser
  ```
- Do not use `--privileged` or `--cap-add=ALL` unless necessary.
- Limit capabilities:
  ```bash
  docker run --cap-drop ALL --cap-add NET_BIND_SERVICE your-image
  ```

## 3. Secrets Management
- Do not bake secrets into images or ENV vars in VCS.
- Use Docker secrets (Swarm) or external vaults (HashiCorp Vault).
- Example with Docker Compose v3.7+:
  ```yaml
  secrets:
    db_password:
      file: ./secrets/db_password.txt
  services:
    app:
      image: myapp
      secrets:
        - db_password
  ```

## 4. Image Scanning
- Scan images for vulnerabilities:
  ```bash
  trivy image your-image:tag
  ```
- Integrate scans into CI pipelines.

## 5. Docker Bench for Security
- Audit host and daemon configuration:
  ```bash
  docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    docker/docker-bench-security
  ```

## 6. Runtime Hardening
- Enable seccomp and AppArmor profiles:
  ```bash
  docker run --security-opt seccomp=default.json your-image
  ```
- Use read-only root filesystem:
  ```bash
  docker run --read-only your-image
  ```

## 7. Network Segmentation
- Create user-defined bridge networks for services:
  ```bash
  docker network create backend
  ```
- Avoid `--network=host` unless absolutely necessary.

## 8. Keep Images Updated
- Rebuild images regularly to pick up patches.
- Pin base image versions (`python:3.11.5-slim`).

## 9. Monitoring & Logging
- Centralize logs (e.g., ELK, Prometheus).
- Monitor running containers and unusual activity.

## 10. Additional Resources
- Docker security docs: https://docs.docker.com/engine/security/
- CIS Docker Benchmark: https://github.com/docker/docker-bench-security
- Trivy: https://github.com/aquasecurity/trivy
