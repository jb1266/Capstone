# #!/bin/bash



# 1. Set the working directory
cd /home/ubuntu/CapstoneProject
echo "CapstoneProject directory selected " $DATE >> /home/abd.log


# 2. FORCE environment variables (This fixes the PM2 /etc/.pm2 error)
export HOME=/home/ubuntu
export PM2_HOME=/home/ubuntu/.pm2
# Ensure npm/node are in the path (adjust path if you use NVM)
export PATH=$PATH:/usr/bin:/usr/local/bin
echo "Environment variables adjusted " $DATE >> /home/abd.log

# 3. Install dependencies
# We run this as ubuntu to ensure package-lock.json isn't owned by root

# 4. Install PM2 if not present
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    sudo npm install -g pm2
    echo "PM2 installed " $DATE >> /home/abd.log
fi

# 4. Manage PM2
# We use the full path to pm2 or ensure it's in the export path above
pm2 delete "CapstoneProject" || true
pm2 start app.js --name "CapstoneProject" --update-env
echo "PM2 start app.js successful " $DATE >> /home/abd.log

echo "Writing custom Caddyfile configuration..."

node app.js
echo "node app.js command successful " $DATE >> /home/abd.log

# Write the config
sudo bash -c 'cat <<EOF > /etc/caddy/Caddyfile
:80 {
    reverse_proxy localhost:3000
    encode gzip
}
EOF'
echo "Caddyfile rewrite successful " $DATE >> /home/abd.log

# Validate and Restart/Reload
# We use 'restart' here for the initial setup to ensure a clean state
if sudo caddy validate --config /etc/caddy/Caddyfile; then
    echo "Caddyfile validated. Applying configuration..."
    sudo systemctl restart caddy
    echo "Caddy restart successful " $DATE >> /home/abd.log
else
    echo "Caddyfile validation failed!" $DATE >> /home/abd.log
    exit 1
fi

echo "Setup complete! Caddy is now proxying :80 to :3000."

# To get private ip address
echo "<h1>$(hostname -I | awk '{print $1}')</h1>" >> /home/ubuntu/CapstoneProject/public/index.html
echo "Hostname added to webpage " $DATE >> /home/abd.log

# 5. Save state
pm2 save