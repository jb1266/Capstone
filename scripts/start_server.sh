#!/bin/bash

# Navigate to the app directory
cd /home/ubuntu/CapstoneProject

# Install pm2 globally if it's not already there
sudo npm install pm2 -g

# Install the app dependencies (the ones from your package.json)
npm install

# Stop the app if it's already running (prevents port conflicts)
pm2 stop CapstoneProject || true

# Start the app and give it a recognizable name
# We use '--update-env' to ensure any new environment variables are picked up
pm2 start app.js --name "CapstoneProject" --update-env

# Save the pm2 list so it restarts if the whole EC2 instance reboots
pm2 save