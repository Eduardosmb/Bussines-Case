import '../services/auth_service.dart';

/// Test utility to help verify the authentication system
class TestAuth {
  static final AuthService _authService = AuthService();

  /// Print all registered users (for testing purposes)
  static Future<void> printAllUsers() async {
    final users = await _authService.getAllUsers();
    print('=== REGISTERED USERS ===');
    if (users.isEmpty) {
      print('No users registered yet.');
    } else {
      for (var user in users) {
        print('Email: ${user.email}');
        print('Name: ${user.fullName}');
        print('Referral Code: ${user.referralCode}');
        print('Created: ${user.createdAt}');
        print('---');
      }
    }
  }

  /// Check current login status
  static Future<void> checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final currentUser = await _authService.getCurrentUser();
    
    print('=== LOGIN STATUS ===');
    print('Is Logged In: $isLoggedIn');
    if (currentUser != null) {
      print('Current User: ${currentUser.fullName} (${currentUser.email})');
    } else {
      print('No user currently logged in');
    }
  }

  /// Clear all data (useful for testing)
  static Future<void> clearAllData() async {
    await _authService.clearAllData();
    print('All authentication data cleared.');
  }

  /// Test registration with sample data
  static Future<void> testRegistration() async {
    print('=== TESTING REGISTRATION ===');
    
    final result = await _authService.register(
      email: 'test@example.com',
      password: 'password123',
      firstName: 'Test',
      lastName: 'User',
    );

    if (result.success) {
      print('✅ Registration successful!');
      print('User: ${result.user!.fullName}');
      print('Email: ${result.user!.email}');
      print('Referral Code: ${result.user!.referralCode}');
    } else {
      print('❌ Registration failed: ${result.error}');
    }
  }

  /// Test login with sample data
  static Future<void> testLogin() async {
    print('=== TESTING LOGIN ===');
    
    final result = await _authService.login(
      email: 'test@example.com',
      password: 'password123',
    );

    if (result.success) {
      print('✅ Login successful!');
      print('User: ${result.user!.fullName}');
    } else {
      print('❌ Login failed: ${result.error}');
    }
  }
}
