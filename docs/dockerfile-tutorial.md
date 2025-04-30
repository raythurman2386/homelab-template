# Dockerfile Tutorial

This guide covers the fundamentals of writing and optimizing a `Dockerfile`.

## Basic Structure

```dockerfile
# Base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . /app

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Multi-stage Builds

Use multi-stage builds to keep images slim:

```dockerfile
FROM node:18 AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install
COPY . .
RUN yarn build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
```

## Tips

- Use official base images when possible.
- Pin image versions (`python:3.11.5-slim`).
- Use `.dockerignore` to exclude unnecessary files.
- Order layers by volatility (rarely changing at top).
- Clean up caches and lists to reduce image size.
