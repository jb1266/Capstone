#!/bin/bash

# 1. Update the system package list
sudo apt-get update -y

# 2. Install MySQL Server
# 'export DEBIAN_FRONTEND=noninteractive' prevents MySQL from asking for 
# a password during installation so the build doesn't hang.
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y mysql-server

# 3. Install Node.js (Version 20.x)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 4. Verify installations (visible in AWS CodeDeploy logs)
node -v
npm -v
mysql --version

# 5. Start and enable MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql