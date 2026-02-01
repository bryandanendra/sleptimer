#!/bin/bash

# RestClock Installation Script
# This script builds the app in release mode and installs it to /Applications

set -e  # Exit on error

echo "🚀 Building RestClock..."
echo "This may take a few minutes..."

# Build release version
flutter build macos --release

echo ""
echo "✅ Build complete!"
echo ""

# App path
APP_PATH="build/macos/Build/Products/Release/sleptimer.app"
INSTALL_PATH="/Applications/RestClock.app"

# Check if app was built
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at $APP_PATH"
    exit 1
fi

echo "📦 Installing to /Applications..."

# Remove old version if exists
if [ -d "$INSTALL_PATH" ]; then
    echo "🗑️  Removing old version..."
    rm -rf "$INSTALL_PATH"
fi

# Copy to Applications
cp -R "$APP_PATH" "$INSTALL_PATH"

echo ""
echo "✅ Installation complete!"
echo ""
echo "🎉 RestClock has been installed to /Applications"
echo ""
echo "To run:"
echo "  - Open Spotlight (Cmd + Space)"
echo "  - Type 'RestClock'"
echo "  - Press Enter"
echo ""
echo "Or find it in your Applications folder!"
echo ""
echo "📝 Note: On first launch, macOS may ask for permissions."
echo "   Just click 'Open' when prompted."
