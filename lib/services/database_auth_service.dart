import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/achievement.dart';
import 'database_service.dart';
import 'achievement_service.dart';

class DatabaseAuthService {
  static final Random _random = Random();
  static const Uuid _uuid = Uuid();

  /// Initialize the service
  static Future<void> initialize() async {
    await DatabaseService.initialize();
    await DatabaseService.createDefaultAdmin();
  }

  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    try {
      // Check if email already exists
      final existingUser = await DatabaseService.getUserByEmail(email);
      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Este e-mail já está cadastrado. Tente fazer login.',
        };
      }

      // Find referrer if referral code provided
      User? referrer;
      if (referralCode != null && referralCode.trim().isNotEmpty) {
        referrer = await DatabaseService.getUserByReferralCode(referralCode.trim().toUpperCase());
      }

      // Create new user
      final user = User(
        id: _uuid.v4(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.toLowerCase().trim(),
        referralCode: _generateReferralCode(),
        totalReferrals: 0,
        totalEarnings: referrer != null ? 25.0 : 0.0, // Bonus only with referral
        createdAt: DateTime.now(),
      );

      // Create user in database
      final passwordHash = _hashPassword(password);
      final createdUser = await DatabaseService.createUser(user, passwordHash);
      
      if (createdUser == null) {
        return {
          'success': false,
          'message': 'Erro ao criar usuário. Tente novamente.',
        };
      }

      // Process referral reward
      if (referrer != null) {
        await _processReferralReward(referrer, user);
      }

      return {
        'success': true,
        'user': user,
        'message': referrer != null 
          ? 'Conta criada com sucesso! Você ganhou R\$25 de bônus!' 
          : 'Conta criada com sucesso!',
      };

    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'message': 'Erro interno. Tente novamente mais tarde.',
      };
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final user = await DatabaseService.getUserByEmail(email);
      if (user == null) {
        return {
          'success': false,
          'message': 'E-mail não encontrado.',
        };
      }

      final storedHash = await DatabaseService.getPasswordHash(email);
      if (storedHash == null || storedHash != _hashPassword(password)) {
        return {
          'success': false,
          'message': 'Senha incorreta.',
        };
      }

      return {
        'success': true,
        'user': user,
        'message': 'Login realizado com sucesso!',
      };

    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'message': 'Erro interno. Tente novamente mais tarde.',
      };
    }
  }

  /// Get all users
  static Future<List<User>> getAllUsers() async {
    return await DatabaseService.getAllUsers();
  }

  /// Process referral reward
  static Future<void> _processReferralReward(User referrer, User newUser) async {
    try {
      // Update referrer's metrics
      final newReferralCount = referrer.totalReferrals + 1;
      final newEarnings = referrer.totalEarnings + 25.0; // Referrer gets $25 too

      await DatabaseService.updateUserMetrics(
        referrer.id,
        newReferralCount,
        newEarnings,
      );

      print('✅ Processed referral reward: ${referrer.email} -> ${newUser.email}');

    } catch (e) {
      print('❌ Error processing referral reward: $e');
    }
  }

  /// Hash password
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate unique referral code
  static String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String code = '';
    
    for (int i = 0; i < 8; i++) {
      code += chars[_random.nextInt(chars.length)];
    }
    
    return code;
  }

  /// Get referral message
  static String generateReferralMessage(User user) {
    return '''Convite CloudWalk 🚀

Olá! Te convido para o programa de recompensas da CloudWalk!

💰 Ganhe R\$25 ao se cadastrar com meu código: ${user.referralCode}

📱 Link do app: https://cloudwalk.app
🔑 Código: ${user.referralCode}

#CloudWalkRewards #InfinityPay''';
  }

  /// Check user achievements
  static Future<List<Achievement>> checkUserAchievements(User user) async {
    final achievementService = AchievementService();
    final allAchievements = await achievementService.getUserAchievements(user.id);
    final unlockedAchievements = <Achievement>[];

    for (final achievement in allAchievements) {
      if (_isAchievementUnlocked(achievement, user)) {
        unlockedAchievements.add(achievement.copyWith(isUnlocked: true));
      }
    }

    return unlockedAchievements;
  }

  /// Check if achievement is unlocked
  static bool _isAchievementUnlocked(Achievement achievement, User user) {
    switch (achievement.id) {
      case 'first_referral':
        return user.totalReferrals >= 1;
      case 'early_adopter':
        return user.totalReferrals >= 5;
      case 'referral_master':
        return user.totalReferrals >= 10;
      case 'money_maker':
        return user.totalEarnings >= 100;
      case 'top_performer':
        return user.totalEarnings >= 500;
      case 'legend':
        return user.totalEarnings >= 1000;
      default:
        return false;
    }
  }

  /// Get total achievement rewards for user
  static Future<double> getTotalAchievementRewards(User user) async {
    final unlockedAchievements = await checkUserAchievements(user);
    return unlockedAchievements.fold<double>(0.0, (sum, achievement) => sum + achievement.rewardAmount);
  }

  /// Populate database with sample data
  static Future<void> populateSampleData() async {
    await DatabaseService.populateWithSampleData();
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    return await DatabaseService.getDatabaseStats();
  }
}
