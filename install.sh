#!/bin/bash

# Virtual Trackpad Installation Script
# This script sets up the Virtual Trackpad application with proper permissions

set -e

echo "Virtual Trackpad Installation Script"
echo "=================================="

# Check if running as root for sudo setup
if [ "$EUID" -eq 0 ]; then
    echo "This script should be run as a regular user, not as root."
    echo "It will prompt for sudo password when needed."
    exit 1
fi

# Get the current username
USER=$(whoami)

echo "Setting up Virtual Trackpad for user: $USER"

# Install ydotool if not already installed
echo "Checking for ydotool..."
if ! command -v ydotool &> /dev/null; then
    echo "Installing ydotool..."
    sudo zypper install -y ydotool
else
    echo "ydotool is already installed"
fi

# Setup passwordless sudo for ydotool
echo "Setting up passwordless sudo for ydotool..."
echo "SkylarStone ALL=(ALL) NOPASSWD: /usr/bin/ydotool" | sudo tee /etc/sudoers.d/ydotool

# Verify the sudoers file was created correctly
if sudo test -f /etc/sudoers.d/ydotool; then
    echo "Passwordless sudo configuration created successfully"
else
    echo "Failed to create sudoers configuration"
    exit 1
fi

# Start ydotoold service
echo "Starting ydotoold service..."
sudo systemctl enable --now ydotoold

# Wait a moment for the service to start
sleep 2

# Check if ydotoold is running
if pgrep -f ydotoold > /dev/null; then
    echo "ydotoold service is running"
else
    echo "Warning: ydotoold service may not be running properly"
fi

# Test ydotool
echo "Testing ydotool functionality..."
if sudo ydotool mousemove_relative -- 1 1; then
    echo "ydotool test successful"
else
    echo "ydotool test failed"
fi

# Build the application
echo "Building Virtual Trackpad application..."
cd "$(dirname "$0")/working_build"
make

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo ""
    echo "Installation complete!"
    echo "To run the Virtual Trackpad:"
    echo "  cd $(pwd)"
    echo "  ./VirtualTrackpadApp"
    echo ""
    echo "The Virtual Trackpad will appear as a floating window where you can:"
    echo "- Drag in the touch area to move your cursor"
    echo "- Click L, M, R buttons for left, middle, right clicks"
    echo "- Drag the title bar to reposition the window"
else
    echo "Build failed"
    exit 1
fi
