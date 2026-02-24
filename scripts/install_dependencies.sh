#!/bin/bash


# Create directory if it doesn't exist
sudo mkdir -p /home/ubuntu/CapstoneProject
sudo chown ubuntu:ubuntu /home/ubuntu/CapstoneProject

# Navigate to project directory
cd /home/ubuntu/CapstoneProject

# Install Node.js and npm if not present
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install MySQL if needed
if ! command -v mysql &> /dev/null; then
    echo "Installing MySQL..."
    sudo apt-get update
    sudo apt-get install -y mysql-server
    sudo systemctl start mysql
    sudo systemctl enable mysql
fi

# Install npm dependencies if package.json exists
if [ -f "package.json" ]; then
    echo "Installing npm dependencies..."
    npm install --production
else
    echo "No package.json found in $(pwd)"
    ls -la
fi



# Insatll Caddy

if ! command -v caddy &> /dev/null; then
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    chmod o+r /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install caddy
fi

echo "Writing custom Caddyfile configuration..."

# Ensure the directory exists (just in case)
sudo mkdir -p /etc/caddy

# Write the config
sudo bash -c 'cat <<EOF > /etc/caddy/Caddyfile
:80 {
    reverse_proxy localhost:3000
    encode gzip
}
EOF'

# Validate and Restart/Reload
# We use 'restart' here for the initial setup to ensure a clean state
if sudo caddy validate --config /etc/caddy/Caddyfile; then
    echo "Caddyfile validated. Applying configuration..."
    sudo systemctl restart caddy
else
    echo "Caddyfile validation failed!"
    exit 1
fi

echo "Setup complete! Caddy is now proxying :80 to :3000."



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