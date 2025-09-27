# CloudWalk Referral System

A Flutter web application for CloudWalk's referral program with AI-powered insights.

## Features

- 🔐 User authentication and registration
- 💰 Referral tracking with earnings system  
- 🏆 Achievement system with rewards
- 📊 Leaderboard with top performers
- 🤖 AI Assistant powered by OpenAI GPT-4
- 👨‍💼 Admin dashboard with advanced analytics

## Quick Start

1. Install dependencies:
```bash
flutter pub get
```

2. Create `.env` file with:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENAI_API_KEY=your_openai_api_key
OPENAI_ORGANIZATION_ID=your_openai_org_id
```

3. Run the app:
```bash
flutter run -t lib/main_simple_test.dart
```

## Project Structure

```
lib/
├── main_simple_test.dart      # Main application entry point
├── models/                    # Data models
│   ├── achievement.dart
│   └── user.dart
├── screens/                   # UI screens
│   ├── ai_agent_screen.dart
│   └── churn_analytics_screen.dart
└── services/                  # Business logic
    ├── admin_service.dart
    ├── advanced_admin_ai_chat.dart
    ├── openai_service.dart
    └── supabase_service.dart
```

## Admin Access

- Email: `admin@cloudwalk.com`
- Password: `123456`

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL)
- **AI**: OpenAI GPT-4
- **Authentication**: Supabase Auth
