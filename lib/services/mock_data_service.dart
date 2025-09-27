import 'dart:math';
import '../models/user.dart';
import '../models/achievement.dart';
import 'auth_service.dart';
import 'achievement_service.dart';
import 'referral_link_service.dart';

class MockDataService {
  static final Random _random = Random();
  
  // Mock user data - LOGICALLY CORRECT referral system
  // Ana referred 4 people: Pedro, Carlos, Rafael, Bruno
  // João referred 2 people: Maria, Camila  
  // Lucia referred 1 person: Fernanda
  // Others have 0 referrals (they were all referred by someone else)
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'firstName': 'João',
      'lastName': 'Silva',
      'email': 'joao.silva@email.com',
      'password': '123456',
      'referrals': 2, // Referred Maria and Camila
      'earnings': 125.0, // 2 referrals × $50 + $25 signup bonus
      'referredBy': null, // Original user
    },
    {
      'firstName': 'Maria',
      'lastName': 'Santos',
      'email': 'maria.santos@email.com',
      'password': '123456',
      'referrals': 0, // Was referred by João
      'earnings': 25.0, // Only signup bonus
      'referredBy': 'joao.silva@email.com',
    },
    {
      'firstName': 'Pedro',
      'lastName': 'Costa',
      'email': 'pedro.costa@email.com',
      'password': '123456',
      'referrals': 0, // Was referred by Ana
      'earnings': 25.0, // Only signup bonus
      'referredBy': 'ana.oliveira@email.com',
    },
    {
      'firstName': 'Ana',
      'lastName': 'Oliveira',
      'email': 'ana.oliveira@email.com',
      'password': '123456',
      'referrals': 4, // Referred Pedro, Carlos, Rafael, Bruno
      'earnings': 200.0, // 4 referrals × $50, no signup bonus (original user)
      'referredBy': null, // Original user
    },
    {
      'firstName': 'Carlos',
      'lastName': 'Ferreira',
      'email': 'carlos.ferreira@email.com',
      'password': '123456',
      'referrals': 0, // Was referred by Ana
      'earnings': 25.0, // Only signup bonus
      'referredBy': 'ana.oliveira@email.com',
    },
    {
      'firstName': 'Lucia',
      'lastName': 'Rodrigues',
      'email': 'lucia.rodrigues@email.com',
      'password': '123456',
      'referrals': 1, // Referred Fernanda
      'earnings': 50.0, // 1 referral × $50, no signup bonus (original user)
      'referredBy': null, // Original user
    },
    {
      'firstName': 'Rafael',
      'lastName': 'Almeida',
      'email': 'rafael.almeida@email.com',
      'password': '123456',
      'referrals': 0, // Was referred by Ana
      'earnings': 25.0, // Only signup bonus
      'referredBy': 'ana.oliveira@email.com',
    },
    {
      'firstName': 'Camila',
      'lastName': 'Lima',
      'email': 'camila.lima@email.com',
      'password': '123456',
      'referrals': 0, // Was referred by João
      'earnings': 25.0, // Only signup bonus
      'referredBy': 'joao.silva@email.com',
    },
    {
      'firstName': 'Bruno',
      'lastName': 'Martins',
      'email': 'bruno.martins@email.com',
      'password': '123456',
      'referrals': 0, // Was referred by Ana
      'earnings': 25.0, // Only signup bonus
      'referredBy': 'ana.oliveira@email.com',
    },
    {
      'firstName': 'Fernanda',
      'lastName': 'Pereira',
      'email': 'fernanda.pereira@email.com',
      'password': '123456',
      'referrals': 0, // Was referred by Lucia
      'earnings': 25.0, // Only signup bonus
      'referredBy': 'lucia.rodrigues@email.com',
    },
  ];

  // Generate a random referral code
  static String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(_random.nextInt(chars.length))));
  }

  // Create mock users and populate the system
  static Future<void> populateMockData() async {
    final authService = AuthService();
    final achievementService = AchievementService();
    
    print('🎭 Creating mock users...');
    
    // Clear existing data first
    await authService.clearAllData();
    
    // Create mock users
    for (int i = 0; i < _mockUsers.length; i++) {
      final mockUser = _mockUsers[i];
      
      // Create user
      final user = User(
        id: (i + 1).toString(),
        email: mockUser['email'],
        firstName: mockUser['firstName'],
        lastName: mockUser['lastName'],
        referralCode: _generateReferralCode(),
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        totalReferrals: mockUser['referrals'],
        totalEarnings: mockUser['earnings'],
      );
      
      // Simulate registration (without going through the full registration process)
      await _simulateUserRegistration(authService, user, mockUser['password']);
      
      // Create and unlock achievements based on user stats
      await _createUserAchievements(achievementService, user);
      
      print('✅ Created user: ${user.fullName} (${user.totalReferrals} referrals, \$${user.totalEarnings})');
    }
    
    // Update leaderboard with all users
    await _updateLeaderboard(achievementService);
    
    // Generate referral links for all users
    print('🔗 Generating referral links...');
    for (final userData in _mockUsers) {
      final user = User(
        id: userData['email'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        referralCode: _generateReferralCode(),
        totalReferrals: userData['referrals'],
        totalEarnings: userData['earnings'],
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
      );
      
      final link = await ReferralLinkService.generateReferralLink(user);
      print('  ✅ ${user.firstName}: ${link.fullUrl}');
    }
    
    // Simulate referral link activity and churn scenarios
    print('📈 Simulating link activity and churn scenarios...');
    await ReferralLinkService.simulateLinkActivity();
    await _simulateChurnScenarios();
    
    print('🏆 Mock data population complete!');
    print('📊 Total users: ${_mockUsers.length}');
    print('🔑 You can login with any email using password: 123456');
    print('💡 Try: joao.silva@email.com / 123456');
  }

  // Simulate user registration without going through the full process
  static Future<void> _simulateUserRegistration(AuthService authService, User user, String password) async {
    try {
      await authService.storeUserDirectly(user, password);
    } catch (e) {
      print('Error creating mock user ${user.email}: $e');
    }
  }

  // Create achievements for a user based on their stats
  static Future<void> _createUserAchievements(AchievementService achievementService, User user) async {
    final achievements = await achievementService.getUserAchievements(user.id);
    final updatedAchievements = <Achievement>[];
    
    for (final achievement in achievements) {
      bool shouldUnlock = false;
      
      switch (achievement.type) {
        case AchievementType.referrals:
          shouldUnlock = user.totalReferrals >= achievement.targetValue;
          break;
        case AchievementType.earnings:
          shouldUnlock = user.totalEarnings >= achievement.targetValue;
          break;
        case AchievementType.special:
          // We'll handle this after creating the leaderboard
          shouldUnlock = false;
          break;
        case AchievementType.streak:
          // Random for streak achievements
          shouldUnlock = _random.nextBool();
          break;
      }
      
      if (shouldUnlock && !achievement.isUnlocked) {
        updatedAchievements.add(achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        ));
      } else {
        updatedAchievements.add(achievement);
      }
    }
    
    await achievementService.saveUserAchievements(user.id, updatedAchievements);
  }

  // Update the leaderboard with mock users
  static Future<void> _updateLeaderboard(AchievementService achievementService) async {
    // Create mock users for leaderboard
    final users = _mockUsers.map((mockUser) {
      return User(
        id: mockUser['email'].hashCode.toString(),
        email: mockUser['email'],
        firstName: mockUser['firstName'],
        lastName: mockUser['lastName'],
        referralCode: _generateReferralCode(),
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        totalReferrals: mockUser['referrals'],
        totalEarnings: mockUser['earnings'],
      );
    }).toList();
    
    await achievementService.updateLeaderboard(users);
  }

  // Get a random mock user for quick testing
  static Map<String, dynamic> getRandomMockUser() {
    return _mockUsers[_random.nextInt(_mockUsers.length)];
  }

  // Get the top performer for testing
  static Map<String, dynamic> getTopPerformer() {
    return _mockUsers.reduce((a, b) => 
        a['referrals'] > b['referrals'] ? a : b);
  }

  // Get a beginner user for testing
  static Map<String, dynamic> getBeginnerUser() {
    return _mockUsers.where((user) => user['referrals'] < 10).first;
  }

  // Quick test login credentials
  static void printTestCredentials() {
    print('\n🔐 TEST LOGIN CREDENTIALS:');
    print('=' * 50);
    
    final top = getTopPerformer();
    final beginner = getBeginnerUser();
    final random = getRandomMockUser();
    
    print('🏆 TOP PERFORMER:');
    print('   Email: ${top['email']}');
    print('   Password: 123456');
    print('   Stats: ${top['referrals']} referrals, \$${top['earnings']}');
    
    print('\n🌱 BEGINNER:');
    print('   Email: ${beginner['email']}');
    print('   Password: 123456');
    print('   Stats: ${beginner['referrals']} referrals, \$${beginner['earnings']}');
    
    print('\n🎲 RANDOM USER:');
    print('   Email: ${random['email']}');
    print('   Password: 123456');
    print('   Stats: ${random['referrals']} referrals, \$${random['earnings']}');
    
    print('=' * 50);
  }

  // Simulate realistic churn scenarios
  static Future<void> _simulateChurnScenarios() async {
    print('🎭 Simulating churn scenarios...');
    
    final links = await ReferralLinkService.getAllReferralLinks();
    
    for (final link in links) {
      // Simulate additional clicks without conversions (churn)
      final additionalClicks = _random.nextInt(8) + 2; // 2-9 additional clicks
      
      for (int i = 0; i < additionalClicks; i++) {
        await ReferralLinkService.trackLinkClick(
          link.linkCode,
          ipAddress: '192.168.1.${_random.nextInt(255)}',
          userAgent: 'Mozilla/5.0 (Mobile; ${_random.nextBool() ? 'Android' : 'iOS'})',
        );
      }
      
      print('  📊 ${link.userName}: +$additionalClicks cliques sem conversão');
    }
    
    // Simulate some partial registrations (started but didn't complete)
    final topLinks = links.take(3).toList();
    for (final link in topLinks) {
      final partialRegistrations = _random.nextInt(3) + 1; // 1-3 partial attempts
      
      for (int i = 0; i < partialRegistrations; i++) {
        // Track click first
        await ReferralLinkService.trackLinkClick(
          link.linkCode,
          ipAddress: '10.0.0.${_random.nextInt(255)}',
          userAgent: 'CloudWalk Mobile App (Partial Registration)',
        );
      }
      
      print('  ⚠️ ${link.userName}: $partialRegistrations tentativas parciais');
    }
    
    print('📊 Churn scenarios created!');
  }
}
