#!/bin/bash

echo "📱 Testing CloudWalk App with PostgreSQL on Mobile..."

# Check if database is running
if ! docker ps | grep -q "cloudwalk_postgres"; then
    echo "❌ PostgreSQL is not running. Starting it now..."
    ./start_database.sh
    sleep 5
fi

echo "✅ PostgreSQL is running"

# Check available devices
echo "📱 Checking available devices..."
flutter devices

echo ""
echo "🚀 Choose a platform to test:"
echo "1. Android"
echo "2. iOS" 
echo "3. Web (will use fallback mode)"
echo ""

read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo "🤖 Running on Android..."
        flutter run -d android -t lib/main_auth.dart
        ;;
    2)
        echo "🍎 Running on iOS..."
        flutter run -d ios -t lib/main_auth.dart
        ;;
    3)
        echo "🌐 Running on Web (fallback mode)..."
        flutter run -d chrome -t lib/main_auth.dart
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac


