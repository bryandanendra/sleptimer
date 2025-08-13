#!/bin/bash

# Clean and get dependencies
echo "Cleaning and getting dependencies..."
flutter clean
flutter pub get

# Build for macOS
echo "Building for macOS..."
flutter build macos

# Run the app
echo "Running the app..."
open build/macos/Build/Products/Release/sleptimer.app
