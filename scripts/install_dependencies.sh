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


# Change ownership of the application folder to the ubuntu user
sudo chown -R ubuntu:ubuntu /home/ubuntu/CapstoneProject

# Make sure all scripts in the scripts folder are executable
sudo chmod +x /home/ubuntu/CapstoneProject/scripts/*.sh

# Optional: Ensure the web folder is readable
sudo chmod -R 755 /home/ubuntu/CapstoneProject/public


#  Verify installations (visible in AWS CodeDeploy logs)
node -v
npm -v
mysql --version

echo "Dependencies installation completed"