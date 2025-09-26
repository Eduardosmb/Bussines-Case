class AppConfig {
  static const String appName = 'ReferralApp';
  static const String appVersion = '1.0.0';
  
  // Environment
  static const bool isProduction = false;
  static const String baseUrl = isProduction 
    ? 'https://api.referralapp.com'
    : 'https://dev-api.referralapp.com';
    
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String referralsCollection = 'referrals';
  static const String rewardsCollection = 'rewards';
  
  // App Constants
  static const int minPasswordLength = 8;
  static const int referralCodeLength = 6;
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // Rewards Configuration
  static const double referralReward = 50.0;
  static const double signupBonus = 25.0;
  static const String currency = 'USD';
}
