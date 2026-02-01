#!/bin/bash
echo "🧹 Cleaning RestClock build..."

# Clean Flutter
flutter clean

# Remove additional cache
rm -rf .dart_tool/
rm -rf .flutter-plugins-dependencies

# Get dependencies
flutter pub get

echo "✅ Clean completed!"
echo "🚀 To rebuild: flutter build macos --release"
