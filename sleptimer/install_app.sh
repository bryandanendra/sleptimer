#!/bin/bash

# RestClock Installation Script
echo "🚀 Installing RestClock..."

# Navigate to project directory
cd "$(dirname "$0")"

# Check if app is built
if [ ! -d "build/macos/Build/Products/Release/sleptimer.app" ]; then
    echo "❌ App not built. Building now..."
    flutter build macos --release
    if [ $? -ne 0 ]; then
        echo "❌ Build failed. Please check Flutter installation."
        exit 1
    fi
fi

# Create Applications directory if it doesn't exist
INSTALL_DIR="$HOME/Applications/RestClock"
mkdir -p "$INSTALL_DIR"

# Copy app to Applications
echo "📦 Copying RestClock to Applications..."
cp -R "build/macos/Build/Products/Release/sleptimer.app" "$INSTALL_DIR/"

# Set permissions
chmod +x "$INSTALL_DIR/sleptimer.app/Contents/MacOS/sleptimer"

echo "✅ RestClock installed successfully!"
echo ""
echo "📍 Location: $INSTALL_DIR/sleptimer.app"
echo ""
echo "🎯 To launch RestClock:"
echo "   1. Open Finder"
echo "   2. Go to Applications > RestClock"
echo "   3. Double-click RestClock.app"
echo ""
echo "🔄 Or use command line:"
echo "   open $INSTALL_DIR/sleptimer.app"
echo ""
echo "📋 Features:"
echo "   • Timer mode: Set countdown duration"
echo "   • Time mode: Set target time for sleep/shutdown"
echo "   • Menu bar integration"
echo "   • Sleep and Shutdown options"
echo ""
echo "🎉 Enjoy using RestClock!"
