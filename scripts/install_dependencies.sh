#!/bin/bash

# Update package list and upgrade
sudo apt update && sudo apt upgrade -y
echo "update and upgrade passed " $DATE >> /home/abc.log
# chmod +x scripts/*.sh


# Install Node.js and npm if not present
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    sudo apt install -y nodejs npm
    echo "node and npm installed " $DATE >> /home/abc.log
fi

# Create directory if it doesn't exist
sudo mkdir -p /home/ubuntu/CapstoneProject
sudo chown ubuntu:ubuntu /home/ubuntu/CapstoneProject
echo "CapstoneProject directory created " $DATE >> /home/abc.log

# Navigate to project directory
cd /home/ubuntu/CapstoneProject
echo "CapstoneProject directory selected " $DATE >> /home/abc.log


# Install npm dependencies if package.json exists
if [ -f "/home/ubuntu/CapstoneProject/package.json" ]; then
    echo "Installing npm dependencies..."
    npm install mysql2
    npm install --production
    echo "npm dependencies installed " $DATE >> /home/abc.log

else
    echo "No package.json found in $(pwd) " $DATE >> /home/abc.log
    ls -la
fi

# Ensure the directory exists (just in case)
sudo mkdir -p /etc/caddy
echo "Caddy directory created " $DATE >> /home/abc.log


# Install Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
chmod o+r /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy
sudo systemctl start caddy
sudo systemctl enable caddy
echo "Caddy installed and running " $DATE >> /home/abc.log






# if ! command -v caddy &> /dev/null; then
#     echo "Installing Caddy Server..."
    
#     # 1. Install required dependencies for adding the repo
#     sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
    
#     # 2. Add Caddy's official GPG key and repository
#     curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
#     sudo chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg

#     # Add repository list
#     curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
#     sudo chmod o+r /etc/apt/sources.list.d/caddy-stable.list
    
#     # 3. Update and Install
#     sudo apt-get update
#     sudo apt-get install -y caddy
    
#     echo "Caddy installed successfully."
# fi


# echo "Writing custom Caddyfile configuration..."

# # Overwrite the default Caddyfile with your custom proxy config
# sudo bash -c 'cat <<EOF > /etc/caddy/Caddyfile
# :80 {
#     # Reverse proxy to your application running on port 3000
#     reverse_proxy localhost:3000

#     # Optional: Enable compression for better performance
#     encode gzip
# }
# EOF'

# # Validate the new configuration for syntax errors
# if sudo caddy validate --config /etc/caddy/Caddyfile; then
#     echo "Caddyfile validated successfully. Reloading Caddy..."
#     sudo systemctl reload caddy
# else
#     echo "Caddyfile validation failed! Please check the syntax."
#     exit 1
# fi

# echo "Setup complete! Caddy is now proxying :80 to :3000."

# Ending noti
echo "Dependencies installation completed"