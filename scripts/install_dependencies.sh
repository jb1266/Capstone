#!/bin/bash

# The following bash script is to create a custom AMI

# Update package list and upgrade
sudo apt update && sudo apt upgrade -y

# Installed SSM Agent
sudo snap install amazon-ssm-agent --classic


# Install Node.js and npm if not present
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    sudo apt install -y nodejs npm
fi

# Create directory if it doesn't exist
sudo mkdir -p /home/ubuntu/CapstoneProject

# Set proper ownership and permissions
chown -R ubuntu:ubuntu /home/ubuntu/CapstoneProject
chmod -R 755 /home/ubuntu/CapstoneProject
chmod +x scripts/*.sh

# Navigate to project directory
cd /home/ubuntu/CapstoneProject


# Install npm dependencies if package.json exists
if [ -f "/home/ubuntu/CapstoneProject/package.json" ]; then
    echo "Installing npm dependencies..."
    npm install mysql2
    npm install --production

else
    ls -la
fi

# 4. Install PM2 if not present
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    sudo npm install -g pm2
fi


# Ensure the directory exists (just in case)
sudo mkdir -p /etc/caddy


# Install Caddy
if ! command -v caddy &> /dev/null; then
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    chmod o+r /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install -y caddy
    sudo systemctl start caddy
    sudo systemctl enable caddy
fi



