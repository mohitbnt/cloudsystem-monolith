#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# ==============================================================================
# 1. Set Non-Interactive Environment
# ==============================================================================
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a  # HIGHLIGHT: Automatically restarts services without menus

echo "=== 2. Updating System Packages ==="
sudo -E apt-get update -y
sudo -E apt-get upgrade -y -o Dpkg::Options::="--force-confold" --with-new-pkgs

echo "=== 3. Installing Base Utilities ==="
sudo -E apt-get install -y \
    curl \
    git \
    build-essential \
    software-properties-common \
    unzip \
    jq

echo "=== 4. Installing Node.js (v20 LTS) ==="
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo -E apt-get install -y nodejs
echo "Verified Node version: $(node -v)"
echo "Verified npm version: $(npm -v)"

echo "=== 5. Installing Nginx ==="
sudo -E apt-get install -y nginx
sudo systemctl enable nginx

echo "=== 6. Installing AWS CLI ==="
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws

echo "===7. Managing SSM Agent Service ==="
if systemctl list-unit-files | grep -q "^amazon-ssm-agent.service"; then
    sudo systemctl enable --now amazon-ssm-agent.service
elif systemctl list-unit-files | grep -q "^snap.amazon-ssm-agent.amazon-ssm-agent.service"; then
    sudo systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service
else
    echo "SSM agent service unit not found. Installing via snap..."
    sudo snap install amazon-ssm-agent --classic
    sudo systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service
fi

echo "=== 8. Creating Application Directory & System User ==="
sudo mkdir -p /var/www/medusa
sudo chown -R ubuntu:ubuntu /var/www/medusa

echo "=== Script Execution Completed Successfully! ==="
