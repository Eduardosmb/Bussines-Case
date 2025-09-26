#!/bin/bash

echo "🚀 Setting up ReferralApp Flutter Project"
echo "========================================"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   sudo snap install flutter --classic"
    echo "   OR follow: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Navigate to project directory
cd "$(dirname "$0")"

echo "📦 Installing Flutter dependencies..."
flutter pub get

echo "🔍 Running Flutter Doctor..."
flutter doctor

echo "📱 Available devices:"
flutter devices

echo ""
echo "🎉 Setup complete! To run the app:"
echo "   flutter run"
echo ""
echo "🔥 To run with hot reload on a specific device:"
echo "   flutter run -d chrome      # For web"
echo "   flutter run -d android     # For Android emulator"
echo "   flutter run -d ios         # For iOS simulator"
echo ""
echo "🛠️  Note: You'll need to set up Firebase before the app works fully."
echo "   See README.md for Firebase setup instructions."
