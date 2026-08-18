#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# ==============================================================================
# 1. Set Non-Interactive Environment
# ==============================================================================
export DEBIAN_FRONTEND=noninteractive

echo "=== 2. Updating System Packages ==="
sudo apt-get update -y
sudo apt-get upgrade -y

echo "=== 3. Installing Base Utilities ==="
sudo apt-get install -y \
    curl \
    git \
    build-essential \
    software-properties-common \
    unzip \
    jq

echo "=== 4. Installing Node.js (v20 LTS) ==="
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
echo "Verified Node version: $(node -v)"
echo "Verified npm version: $(npm -v)"

echo "=== 5. Installing Nginx ==="
sudo apt-get install -y nginx
sudo systemctl enable nginx

echo "=== 6. Installing AWS Tools ==="
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws

# Ensure AWS SSM Agent is active
if systemctl list-unit-files | grep -q ssm-agent; then
    sudo systemctl enable amazon-ssm-agent
else
    echo "SSM Agent not found. Installing snap version..."
    sudo snap install amazon-ssm-agent --classic
    sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
fi

echo "=== 7. Creating Application Directory & System User ==="
sudo mkdir -p /var/www/medusa
sudo chown -R ubuntu:ubuntu /var/www/medusa

echo "=== Script Execution Completed Successfully! ==="