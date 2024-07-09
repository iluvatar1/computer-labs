#!/bin/bash

# Source the configuration file
. /etc/default/earlyoom

# Function to clean up PID file
cleanup() {
    rm -f /var/run/earlyoom.pid
}

# Set trap to clean up on exit
trap cleanup EXIT

# Start earlyoom with proper logging
/usr/local/bin/earlyoom $EARLYOOM_ARGS >> /var/log/earlyoom.log 2>&1 &

# Save the PID for easier management
echo $! > /var/run/earlyoom.pid

# Wait a moment to ensure the process has started
sleep 2

# Check if the process is running
if pgrep -F /var/run/earlyoom.pid > /dev/null; then
    echo "earlyoom started successfully with PID $(cat /var/run/earlyoom.pid)"
    exit 0
else
    echo "Failed to start earlyoom"
    rm -f /var/run/earlyoom.pid
    exit 1
fi

