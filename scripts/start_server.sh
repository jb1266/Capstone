# #!/bin/bash

# # Navigate to the app directory
# cd /home/ubuntu/CapstoneProject

# # Install pm2 globally if it's not already there
# sudo npm install pm2 -g

# # Install the app dependencies (the ones from your package.json)
# npm install

# # Stop the app if it's already running (prevents port conflicts)
# pm2 stop CapstoneProject || true

# # Start the app and give it a recognizable name
# # We use '--update-env' to ensure any new environment variables are picked up
# pm2 start app.js --name "CapstoneProject" --update-env

# # Save the pm2 list so it restarts if the whole EC2 instance reboots
# pm2 save


#!/bin/bash

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

# 4. Manage PM2
# We use the full path to pm2 or ensure it's in the export path above
pm2 delete "CapstoneProject" || true
pm2 start app.js --name "CapstoneProject" --update-env

# To get private ip address
echo "<h1>$(hostname -f)</h1>" >> ../public/index.html

# 5. Save state
pm2 save