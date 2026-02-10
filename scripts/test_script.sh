#!/bin/bash

# Change ownership of the application folder to the ubuntu user
sudo chown -R ubuntu:ubuntu /home/ubuntu/CapstoneProject

# Make sure all scripts in the scripts folder are executable
sudo chmod +x /home/ubuntu/CapstoneProject/scripts/*.sh

# Optional: Ensure the web folder is readable
sudo chmod -R 755 /home/ubuntu/CapstoneProject/public