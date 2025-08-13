#!/bin/bash

# Script untuk mengupdate tray icon Sleep Timer
echo "🔄 Updating tray icon..."

# Navigate to project directory
cd "$(dirname "$0")"

# Copy icon dari menuicon.png ke assets
echo "📋 Copying menu icon to assets..."
if [ -f "menuicon.png" ]; then
    cp menuicon.png assets/icon.png
    echo "✅ Using custom menu icon (menuicon.png)"
else
    echo "⚠️  menuicon.png not found, using default app icon"
    cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png assets/icon.png
fi

# Verify the copy
if [ -f "assets/icon.png" ]; then
    echo "✅ Icon copied successfully"
    echo "📏 Icon size: $(ls -lh assets/icon.png | awk '{print $5}')"
else
    echo "❌ Failed to copy icon"
    exit 1
fi

# Build the app
echo "🔨 Building app..."
flutter build macos

if [ $? -eq 0 ]; then
    echo "✅ Build successful"
    echo "🚀 Ready to launch with new icon"
    echo ""
    echo "To launch the app:"
    echo "  ./launch_app.command"
else
    echo "❌ Build failed"
    exit 1
fi
