#!/bin/bash

# Create necessary directories
mkdir -p /etc/traefik/dynamic
mkdir -p /etc/traefik/certs

# Copy configuration files
cp traefik.yml /etc/traefik/
cp dynamic.yml /etc/traefik/dynamic/

# Set proper permissions
chmod 600 /etc/traefik/acme.json
chown -R root:root /etc/traefik

# Install certbot if not already installed
if ! command -v certbot &> /dev/null; then
    apt-get update
    apt-get install -y certbot
fi

# Stop any running Traefik instance
systemctl stop traefik

# Start Traefik with new configuration
systemctl start traefik

# Check Traefik status
systemctl status traefik

echo "SSL setup completed. Please check Traefik logs for any issues." 