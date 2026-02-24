#!/bin/bash

# # 1. Update the system package list
# sudo apt-get update -y

# # 2. Install MySQL Server
# # 'export DEBIAN_FRONTEND=noninteractive' prevents MySQL from asking for 
# # a password during installation so the build doesn't hang.
# export DEBIAN_FRONTEND=noninteractive
# sudo apt-get install -y mysql-server

# # 3. Install Node.js (Version 20.x)
# curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
# sudo apt-get install -y nodejs

# # 4. Verify installations (visible in AWS CodeDeploy logs)
# node -v
# npm -v
# mysql --version

# # 5. Start and enable MySQL service
# sudo systemctl start mysql
# sudo systemctl enable mysql



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


# 1. Add the keyring
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
sudo chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg

# 2. Add the repository list
echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] https://dl.cloudsmith.io/public/caddy/stable/debian any main" | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo chmod o+r /etc/apt/sources.list.d/caddy-stable.list

# 3. Update and install
sudo apt update
sudo apt install caddy


echo "Writing custom Caddyfile configuration..."

# Overwrite the default Caddyfile with your custom proxy config
sudo bash -c 'cat <<EOF > /etc/caddy/Caddyfile
:80 {
    # Reverse proxy to your application running on port 3000
    reverse_proxy localhost:3000

    # Optional: Enable compression for better performance
    encode gzip
}
EOF'

# Validate the new configuration for syntax errors
if sudo caddy validate --config /etc/caddy/Caddyfile; then
    echo "Caddyfile validated successfully. Reloading Caddy..."
    sudo systemctl reload caddy
else
    echo "Caddyfile validation failed! Please check the syntax."
    exit 1
fi

echo "Setup complete! Caddy is now proxying :80 to :3000."

# Ending noti
echo "Dependencies installation completed"