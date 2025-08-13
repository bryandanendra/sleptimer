#!/bin/bash

# RestClock DMG Creator Script
echo "📦 Creating RestClock DMG installer..."

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

# Create DMG directory
DMG_DIR="RestClock_DMG"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
echo "📋 Copying RestClock to DMG..."
cp -R "build/macos/Build/Products/Release/sleptimer.app" "$DMG_DIR/"

# Create Applications shortcut
echo "🔗 Creating Applications shortcut..."
ln -s "/Applications" "$DMG_DIR/Applications"

# Create DMG file
DMG_NAME="RestClock_v1.0.dmg"
echo "🎯 Creating DMG file: $DMG_NAME"

# Remove existing DMG
rm -f "$DMG_NAME"

# Create DMG using hdiutil
hdiutil create -volname "RestClock" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG_NAME"

if [ $? -eq 0 ]; then
    echo "✅ DMG created successfully!"
    echo ""
    echo "📁 DMG Location: $(pwd)/$DMG_NAME"
    echo "📏 DMG Size: $(du -h "$DMG_NAME" | cut -f1)"
    echo ""
    echo "🎯 To install RestClock:"
    echo "   1. Double-click $DMG_NAME"
    echo "   2. Drag RestClock.app to Applications folder"
    echo "   3. Launch from Applications"
    echo ""
    echo "🎉 DMG installer ready for distribution!"
else
    echo "❌ Failed to create DMG"
    exit 1
fi

# Clean up
rm -rf "$DMG_DIR"
