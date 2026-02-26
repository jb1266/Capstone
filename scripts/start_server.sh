# #!/bin/bash



# 1. Set the working directory
cd /home/ubuntu/CapstoneProject

# 2. FORCE environment variables (This fixes the PM2 /etc/.pm2 error)
export HOME=/home/ubuntu
export PM2_HOME=/home/ubuntu/.pm2
# Ensure npm/node are in the path (adjust path if you use NVM)
export PATH=$PATH:/usr/bin:/usr/local/bin

# 3. Install dependencies
# We run this as ubuntu to ensure package-lock.json isn't owned by root
npm install

# 4. Install PM2 if not present
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    sudo npm install -g pm2
fi

# 4. Manage PM2
# We use the full path to pm2 or ensure it's in the export path above
pm2 delete "CapstoneProject" || true
pm2 start app.js --name "CapstoneProject" --update-env

echo "Writing custom Caddyfile configuration..."


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

# To get private ip address
echo "<h1>$(hostname -I | awk '{print $1}')</h1>" >> /home/ubuntu/public/index.html

# 5. Save state
pm2 save