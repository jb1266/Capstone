#!/bin/bash
# Stop any running Node.js processes
pkill -f "node" || true

# Or if you're using PM2
# pm2 stop all || true

# Or if you're using systemd
# sudo systemctl stop your-app-name || true

echo "Application stopped successfully"
