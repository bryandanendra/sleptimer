#!/bin/bash

echo "🔄 Updating RestClock icons..."

# Check if menuicon.png exists for tray icon
if [ -f "menuicon.png" ]; then
    echo "📋 Copying menuicon.png to assets/icon.png (for menu bar)"
    cp menuicon.png assets/icon.png
    echo "✅ Menu bar icon updated to menuicon.png"
else
    echo "⚠️  menuicon.png not found, using app_icon_32.png for menu bar"
    cp macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png assets/icon.png
fi

# Check if appicon.png exists for app icon
if [ -f "appicon.png" ]; then
    echo "📋 Updating app icons with appicon.png"
    
    # Update all app icon sizes
    sips -z 16 16 appicon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png
    sips -z 32 32 appicon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png
    sips -z 64 64 appicon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png
    sips -z 128 128 appicon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png
    sips -z 256 256 appicon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png
    sips -z 512 512 appicon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png
    sips -z 1024 1024 appicon.png --out macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png
    
    echo "✅ App icons updated to appicon.png"
else
    echo "⚠️  appicon.png not found, keeping existing app icons"
fi

echo ""
echo "🎯 Icon Configuration:"
echo "   • Menu Bar (Tray): assets/icon.png"
echo "   • App Icon (Dock/Applications): AppIcon.appiconset/*.png"
echo ""
echo "🚀 Building RestClock with updated icons..."
flutter clean
flutter pub get
flutter build macos --release

echo ""
echo "✅ RestClock built with updated icons!"
echo "📍 To install: ./install_app.sh"
echo "📍 To create DMG: ./create_dmg.sh"
