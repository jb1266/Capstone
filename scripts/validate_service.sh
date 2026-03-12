#!/bin/bash

# validate_service.sh - Check if the application is running and responding

echo "Starting service validation..."

# Wait a moment for the service to fully start
sleep 5

# Check if the process is running
if pgrep -f "node" > /dev/null; then
    echo "✓ Node.js process is running"
else
    echo "✗ Node.js process is not running"
    exit 1
fi

# Check if the application is responding on the expected port
# Adjust the port number to match your application
APP_PORT=3000
HEALTH_ENDPOINT="http://localhost:${APP_PORT}"

echo "Checking application health at ${HEALTH_ENDPOINT}..."

# Try to connect to the application
if curl -f -s --connect-timeout 10 --max-time 30 "${HEALTH_ENDPOINT}" > /dev/null; then
    echo "✓ Application is responding on port ${APP_PORT}"
else
    echo "✗ Application is not responding on port ${APP_PORT}"
    echo "Checking if port is listening..."
    
    # Check if something is listening on the port
    if netstat -tuln | grep ":${APP_PORT} " > /dev/null; then
        echo "✓ Port ${APP_PORT} is listening"
        echo "✗ But application is not responding to HTTP requests"
    else
        echo "✗ Nothing is listening on port ${APP_PORT}"
    fi
    
    exit 1
fi

echo "✓ Service validation completed successfully"
exit 0
