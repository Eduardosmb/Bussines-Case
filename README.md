# ReferralApp - Member-Get-Member Flutter Application

A modern, AI-powered member-get-member referral application built with Flutter, featuring Firebase authentication, real-time tracking, and gamified rewards.

## 🚀 Project Overview

This application is designed to accelerate growth through referrals by providing users with an intuitive mobile platform to:
- **Invite new members** with personalized referral codes
- **Track referral performance** in real-time
- **Earn rewards** through gamified incentive system
- **Analyze growth insights** with AI-powered data agents

## ✨ Features

### ✅ Completed Features
- 🔐 **Authentication System**
  - Email/password registration and login
  - Email verification workflow
  - Password reset functionality
  - Secure user profile management
  
- 🎨 **Modern UI/UX**
  - Material Design 3 components
  - Dark/light theme support
  - Responsive design for all screen sizes
  - Smooth animations and transitions
  
- 🏗️ **Architecture**
  - Clean architecture with feature-based organization
  - Riverpod for state management
  - Go Router for navigation
  - Firebase integration ready

### 🚧 Upcoming Features
- 📱 **Referral System**
  - QR code generation and scanning
  - Social sharing integration
  - Referral link tracking
  
- 🎮 **Gamification**
  - Rewards dashboard
  - Achievement system
  - Leaderboards
  
- 🤖 **AI Data Agent**
  - Performance analytics
  - Growth forecasting
  - Behavioral insights

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.10+
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Functions)
- **Navigation**: Go Router
- **Design**: Material Design 3
- **Fonts**: Google Fonts (Poppins)

## 📋 Prerequisites

- Flutter SDK (3.10 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase project
- Android/iOS development environment

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd referral-app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication and Firestore Database

#### Configure Firebase for Flutter
1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

4. Configure Firebase for your project:
```bash
flutterfire configure
```

5. Update `lib/core/config/firebase_options.dart` with your project's configuration

#### Enable Authentication Methods
1. In Firebase Console, go to Authentication > Sign-in method
2. Enable "Email/Password" authentication
3. Configure authorized domains if needed

#### Set up Firestore Database
1. Go to Firestore Database in Firebase Console
2. Create database in test mode
3. Set up the following collections:
   - `users` - User profiles and stats
   - `referrals` - Referral tracking records
   - `rewards` - Reward transactions

### 4. Run the Application
```bash
# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run on web
flutter run -d web

flutter run -d chrome -t lib/main_auth.dart
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration and constants
│   ├── router/          # Navigation and routing
│   ├── theme/           # App theme and styling
│   ├── utils/           # Utility functions
│   └── screens/         # Global screens (splash, etc.)
├── features/
│   ├── auth/            # Authentication feature
│   │   ├── models/      # Data models
│   │   ├── providers/   # State management
│   │   ├── screens/     # UI screens
│   │   ├── services/    # Business logic
│   │   └── widgets/     # Reusable components
│   ├── home/            # Dashboard feature
│   ├── profile/         # User profile feature
│   ├── referrals/       # Referral management
│   └── rewards/         # Rewards system
└── main.dart           # App entry point
```

## 🔧 Configuration

### App Configuration
Update `lib/core/config/app_config.dart` to modify:
- API endpoints
- App constants
- Feature flags
- Reward amounts

### Theme Customization
Modify `lib/core/theme/app_theme.dart` to:
- Change color schemes
- Update typography
- Customize component styles

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 📱 Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

## 🚀 Deployment

### Firebase Hosting (Web)
```bash
# Build web version
flutter build web

# Deploy to Firebase
firebase deploy --only hosting
```

### App Stores
1. **Google Play Store**: Use the generated `app-release.aab`
2. **Apple App Store**: Use Xcode to upload the iOS build

## 🔐 Security Considerations

- Firebase Security Rules are configured for authenticated users
- User data is encrypted in transit and at rest
- Referral codes are generated using cryptographically secure methods
- Input validation is implemented on both client and server side

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Contact the development team
- Check the [documentation](docs/)

## 🎯 Next Steps

### Immediate Priorities
1. **Complete Referral System**
   - Implement QR code generation
   - Add social sharing functionality
   - Create referral tracking dashboard

2. **Enhance Rewards System**
   - Build comprehensive rewards catalog
   - Implement redemption workflow
   - Add achievement tracking

3. **AI Integration**
   - Develop data collection pipeline
   - Implement analytics dashboard
   - Create AI-powered insights

### Future Enhancements
- Push notifications
- In-app messaging
- Advanced analytics
- A/B testing framework
- Multi-language support

---

Built with ❤️ using Flutter and Firebase