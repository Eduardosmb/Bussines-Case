import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'stored_users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Generate a random referral code
  String _generateReferralCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Hash password for security
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  // Get all stored users
  Future<Map<String, dynamic>> _getStoredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return {};
    return Map<String, dynamic>.from(jsonDecode(usersJson));
  }

  // Save all users
  Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  // Register a new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? referralCode,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return AuthResult.error('Please enter a valid email address (example@domain.com)');
      }

      // Validate required fields
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult.error('First name and last name are required');
      }

      if (password.length < 6) {
        return AuthResult.error('Password must be at least 6 characters long');
      }

      // Check if user already exists
      final users = await _getStoredUsers();
      final emailKey = email.toLowerCase().trim();
      if (users.containsKey(emailKey)) {
        return AuthResult.error('An account with this email already exists. Please use a different email or try signing in.');
      }

      // Validate referral code if provided
      User? referrer;
      if (referralCode != null && referralCode.trim().isNotEmpty) {
        referrer = await _findUserByReferralCode(referralCode.trim().toUpperCase());
        if (referrer == null) {
          return AuthResult.error('Invalid referral code');
        }
      }

      // Create new user - only give signup bonus if they used a referral code
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: emailKey,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        referralCode: _generateReferralCode(),
        createdAt: DateTime.now(),
        totalEarnings: referrer != null ? 25.0 : 0.0, // Only bonus if referred
      );

      // Store user with hashed password
      users[emailKey] = {
        'user': user.toJson(),
        'passwordHash': _hashPassword(password),
      };

      // Process referral rewards if someone referred this user
      if (referrer != null) {
        await _processReferralReward(referrer, user, users);
      }

      await _saveUsers(users);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      final users = await _getStoredUsers();
      final userKey = email.toLowerCase();

      if (!users.containsKey(userKey)) {
        return AuthResult.error('No account found with this email');
      }

      final userData = users[userKey];
      final storedPasswordHash = userData['passwordHash'];
      final providedPasswordHash = _hashPassword(password);

      if (storedPasswordHash != providedPasswordHash) {
        return AuthResult.error('Incorrect password');
      }

      final user = User.fromJson(userData['user']);

      // Save current user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Get current logged-in user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (!isLoggedIn) return null;

      final userJson = prefs.getString(_currentUserKey);
      if (userJson == null) return null;

      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Update user data
  Future<AuthResult> updateUser(User updatedUser) async {
    try {
      final users = await _getStoredUsers();
      final userKey = updatedUser.email.toLowerCase();

      if (!users.containsKey(userKey)) {
        return AuthResult.error('User not found');
      }

      // Update user data while preserving password hash
      final currentData = users[userKey];
      users[userKey] = {
        'user': updatedUser.toJson(),
        'passwordHash': currentData['passwordHash'], // Keep existing password
      };

      await _saveUsers(users);

      // Update current user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.error('Update failed: ${e.toString()}');
    }
  }

  // Get all registered users (for testing)
  Future<List<User>> getAllUsers() async {
    final users = await _getStoredUsers();
    return users.values
        .map((userData) => User.fromJson(userData['user']))
        .toList();
  }

  // Find user by referral code
  Future<User?> _findUserByReferralCode(String referralCode) async {
    final users = await _getStoredUsers();
    for (var userData in users.values) {
      final user = User.fromJson(userData['user']);
      if (user.referralCode.toUpperCase() == referralCode.toUpperCase()) {
        return user;
      }
    }
    return null;
  }

  // Process referral reward
  Future<void> _processReferralReward(User referrer, User newUser, Map<String, dynamic> users) async {
    // Give reward to referrer
    final updatedReferrer = referrer.copyWith(
      totalReferrals: referrer.totalReferrals + 1,
      totalEarnings: referrer.totalEarnings + 50.0, // Referral reward
    );

    // Update referrer in users map
    users[referrer.email] = {
      'user': updatedReferrer.toJson(),
      'passwordHash': users[referrer.email]['passwordHash'],
    };
  }

  // Get referral statistics
  Future<ReferralStats> getReferralStats(String userEmail) async {
    final users = await _getStoredUsers();
    final currentUser = User.fromJson(users[userEmail.toLowerCase()]['user']);
    
    // Count how many people this user referred
    int referredCount = 0;
    double totalEarned = 0.0;
    List<User> referredUsers = [];

    for (var userData in users.values) {
      final user = User.fromJson(userData['user']);
      // Check if this user was referred by current user (you'd need to track this in registration)
      // For now, we'll use the referral count from the user object
    }

    return ReferralStats(
      totalReferrals: currentUser.totalReferrals,
      totalEarnings: currentUser.totalEarnings,
      referredUsers: referredUsers,
    );
  }

  // Share referral code
  String generateReferralMessage(User user) {
    return '''
🎉 Join ReferralApp with my referral code and earn \$25!

Use my referral code: ${user.referralCode}

✅ You get \$25 when you sign up with this code
🎯 I earn \$50 when you join
📱 Start building your own referral network!

Download the app now and start earning!
    ''';
  }

  // Validate referral code format
  bool isValidReferralCodeFormat(String code) {
    return RegExp(r'^[A-Z0-9]{6}$').hasMatch(code.toUpperCase());
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult._({required this.success, this.user, this.error});

  factory AuthResult.success(User user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(success: false, error: message);
  }
}

class ReferralStats {
  final int totalReferrals;
  final double totalEarnings;
  final List<User> referredUsers;

  ReferralStats({
    required this.totalReferrals,
    required this.totalEarnings,
    required this.referredUsers,
  });
}
