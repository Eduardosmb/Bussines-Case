# 🚀 Development Setup Guide

This guide will help you set up and run the ReferralApp Flutter project on your local machine.

## 📋 Prerequisites

### Required Software
- **Flutter SDK** (3.10 or higher)
- **Git** (for version control)
- **VS Code** or **Android Studio** (recommended IDEs)

### Optional (for device testing)
- **Android Studio** (for Android emulator)
- **Xcode** (for iOS simulator - macOS only)
- **Chrome** (for web testing)

## 🛠️ Installation Steps

### 1. Install Flutter

#### Option A: Using Snap (Ubuntu/Linux)
```bash
sudo snap install flutter --classic
```

#### Option B: Manual Installation
```bash
# Download Flutter
cd ~/
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz

# Extract
tar xf flutter_linux_3.16.0-stable.tar.xz

# Add to PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Verify Installation
```bash
flutter --version
flutter doctor
```

### 3. Setup Project

#### Quick Setup (Automated)
```bash
# Run the setup script
./setup.sh
```

#### Manual Setup
```bash
# Navigate to project directory
cd "/home/eduba/Área de trabalho/cloudwalk/Bussines-Case"

# Install dependencies
flutter pub get

# Check everything is working
flutter doctor
flutter devices
```

## 🚀 Running the Application

### Development Mode (with hot reload)
```bash
# Run on web browser (easiest for testing)
flutter run -d web-server --web-port 8080

# Run on Chrome
flutter run -d chrome

# Run on Android emulator (if set up)
flutter run -d android

# Run on iOS simulator (macOS only)
flutter run -d ios
```

### Quick Test Commands
```bash
# List available devices
flutter devices

# Run with specific device
flutter run -d <device-id>

# Run with verbose output
flutter run -v
```

## 🔧 Development Tools

### Recommended VS Code Extensions
- Flutter (Dart-Code.flutter)
- Dart (Dart-Code.dart-code)
- Material Icon Theme
- GitLens

### Useful Commands
```bash
# Hot reload (while app is running)
r

# Hot restart (while app is running)
R

# Quit (while app is running)
q

# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test
```

## 🔥 Firebase Setup (Required for Full Functionality)

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication and Firestore

### 2. Configure Firebase
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure project
flutterfire configure
```

### 3. Enable Authentication
1. In Firebase Console → Authentication → Sign-in method
2. Enable "Email/Password"

## 🐛 Troubleshooting

### Common Issues

#### Flutter Not Found
```bash
# Check PATH
echo $PATH

# Re-add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"
```

#### Dependencies Issues
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

#### Device Not Found
```bash
# For web development (no device needed)
flutter run -d web-server

# For Android (install Android Studio)
# For iOS (macOS + Xcode only)
```

#### Permission Denied
```bash
# Make setup script executable
chmod +x setup.sh
```

## 📱 Testing Without Firebase

The app will run without Firebase, but authentication won't work. You can:

1. **Test UI/UX**: All screens and navigation work
2. **Test Animations**: Splash screen and transitions
3. **Test Forms**: Validation and user interactions

## 🎯 Next Steps After Setup

1. **Test the app**: Run `flutter run -d chrome`
2. **Explore the code**: Check out the project structure
3. **Set up Firebase**: Follow the Firebase setup guide
4. **Start developing**: Add new features or modify existing ones

## 🆘 Getting Help

If you encounter issues:
1. Check `flutter doctor` output
2. Look at the error messages carefully
3. Restart your IDE
4. Try `flutter clean && flutter pub get`

Happy coding! 🎉
