#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Kill any existing instances
pkill -f "sleptimer.app" 2>/dev/null

# Wait a moment
sleep 1

# Launch the app
echo "Launching Sleep Timer..."
open build/macos/Build/Products/Release/sleptimer.app

echo "Sleep Timer launched! Check the menu bar for the icon."
