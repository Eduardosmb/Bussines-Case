import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/referral_link.dart';
import '../models/achievement.dart';

class SupabaseService {
  static SupabaseClient? _client;
  
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await dotenv.load();
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    print('🔍 DEBUG - URL found: ${supabaseUrl != null}');
    print('🔍 DEBUG - Key found: ${supabaseAnonKey != null}');
    print('🔍 DEBUG - URL length: ${supabaseUrl?.length}');
    print('🔍 DEBUG - Key length: ${supabaseAnonKey?.length}');
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase credentials not found in .env file');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    _client = Supabase.instance.client;
    
    print('✅ Supabase initialized successfully');
    
    // Create tables if they don't exist
    await _createTablesIfNeeded();
  }

  static Future<void> _createTablesIfNeeded() async {
    try {
      print('🔍 Checking if tables exist...');
      
      // Check if users table exists by trying to select from it
      await client.from('users').select('id').limit(1);
      print('✅ Users table exists');
      
    } catch (e) {
      print('⚠️ Tables may not exist. Error: $e');
      print('📋 Please create the following tables in your Supabase dashboard:');
      print('''
      
      CREATE TABLE users (
        id text PRIMARY KEY,
        email text UNIQUE NOT NULL,
        first_name text,
        last_name text,
        referral_code text UNIQUE,
        referred_by text,
        total_referrals integer DEFAULT 0,
        total_earnings numeric DEFAULT 0,
        created_at timestamp with time zone DEFAULT now()
      );
      
      CREATE TABLE referral_links (
        id text PRIMARY KEY,
        user_id text REFERENCES users(id),
        user_name text,
        link_code text UNIQUE,
        full_url text,
        click_count integer DEFAULT 0,
        registration_count integer DEFAULT 0,
        created_at timestamp with time zone DEFAULT now()
      );
      ''');
    }
  }

  // ==================== USER OPERATIONS ====================
  
  static Future<User?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? referralCode,
  }) async {
    try {
      print('🔄 Registering user: $email');
      
      // Check if user already exists in our custom table
      try {
        final existingUser = await client
            .from('users')
            .select()
            .eq('email', email)
            .single();
        
        if (existingUser.isNotEmpty) {
          throw Exception('User already exists in our database. Please sign in instead.');
        }
      } catch (e) {
        // User doesn't exist in our table, continue with registration
        print('📝 User not found in custom table, proceeding with registration');
      }
      
      // 1. First, register with Supabase Auth
      print('📧 Creating auth user...');
      final AuthResponse authResponse = await client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }
      
      final authUser = authResponse.user!;
      print('✅ Auth user created: ${authUser.id}');
      
      // 2. Then, create user profile in our custom table
      final userReferralCode = _generateReferralCode();
      final userData = {
        'id': authUser.id, // UUID gerado automaticamente pelo Supabase Auth
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'referral_code': userReferralCode,
        'referred_by': referralCode,
        'total_referrals': 0,
        'total_earnings': referralCode != null ? 25.0 : 0.0, // Signup bonus if referred
      };
      
      // Handle referral bonus (only in Dart code, no database trigger)
      if (referralCode != null && referralCode.isNotEmpty) {
        try {
          print('🎯 Processing referral code: $referralCode');
          await _processReferral(referralCode, authUser.id);
          print('✅ Referral processed successfully - \$50 for referrer, \$25 for new user');
        } catch (e) {
          print('⚠️ Warning: Failed to process referral: $e');
          // Don't fail registration if referral processing fails
        }
      }
      
      print('💾 Inserting user profile into Supabase...');
      print('📝 Data to insert: $userData');
      final response = await client.from('users').insert(userData).select().single();
      print('✅ User profile created successfully: ${response['email']}');
      
      return User(
        id: response['id'] as String,
        email: response['email'] as String,
        firstName: response['first_name'] as String,
        lastName: response['last_name'] as String,
        referralCode: response['referral_code'] as String,
        totalReferrals: response['total_referrals'] as int,
        totalEarnings: (response['total_earnings'] as num).toDouble(),
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    } catch (e) {
      print('❌ Error registering user: $e');
      rethrow;
    }
  }
  
  static Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 Logging in user: $email');
      
      // 1. Sign in with Supabase Auth
      final AuthResponse authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (authResponse.user == null) {
        throw Exception('Invalid email or password');
      }
      
      final authUser = authResponse.user!;
      print('✅ Auth user logged in: ${authUser.id}');
      
      // 2. Get user profile from our custom table
      print('📄 Fetching user profile...');
      final response = await client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();
      
      print('✅ User profile fetched: ${response['email']}');
      
      return User(
        id: response['id'] as String,
        email: response['email'] as String,
        firstName: response['first_name'] as String,
        lastName: response['last_name'] as String,
        referralCode: response['referral_code'] as String,
        totalReferrals: response['total_referrals'] as int,
        totalEarnings: (response['total_earnings'] as num).toDouble(),
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    } catch (e) {
      print('❌ Error logging in: $e');
      rethrow;
    }
  }
  
  static Future<void> logout() async {
    try {
      print('🔄 Logging out user...');
      await client.auth.signOut();
      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error logging out: $e');
      rethrow;
    }
  }
  
  static Future<User?> getCurrentUser() async {
    try {
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        print('🔍 No authenticated user found');
        return null;
      }
      
      print('🔍 Getting current user: ${authUser.id}');
      
      // Get user profile from our custom table
      final response = await client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();
      
      return User(
        id: response['id'] as String,
        email: response['email'] as String,
        firstName: response['first_name'] as String,
        lastName: response['last_name'] as String,
        referralCode: response['referral_code'] as String,
        totalReferrals: response['total_referrals'] as int,
        totalEarnings: (response['total_earnings'] as num).toDouble(),
        createdAt: DateTime.parse(response['created_at'] as String),
      );
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // ==================== REFERRAL OPERATIONS ====================
  
  static Future<ReferralLink?> createReferralLink(String userId, String title) async {
    try {
      final linkCode = _generateReferralCode();
      return ReferralLink(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: 'User',
        linkCode: linkCode,
        fullUrl: 'https://cloudwalk.app/referral/$linkCode',
        createdAt: DateTime.now(),
        clickCount: 0,
        registrationCount: 0,
        clicks: const [],
        completedRegistrations: const [],
      );
    } catch (e) {
      print('Error creating referral link: $e');
      rethrow;
    }
  }

  static Future<List<ReferralLink>> getUserReferralLinks(String userId) async {
    try {
      // Return mock data for now
      return [
        await createReferralLink(userId, 'Convite CloudWalk 🚀') ?? 
        ReferralLink(
          id: '1',
          userId: userId,
          userName: 'User',
          linkCode: _generateReferralCode(),
          fullUrl: 'https://cloudwalk.app/referral/ABC123',
          createdAt: DateTime.now(),
          clickCount: 5,
          registrationCount: 2,
          clicks: const [],
          completedRegistrations: const [],
        ),
      ];
    } catch (e) {
      print('Error getting referral links: $e');
      return [];
    }
  }

  // ==================== ACHIEVEMENT OPERATIONS ====================
  
  static Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      print('🏆 Getting achievements for user: $userId');
      
      // Get user data for progress calculation
      final userResponse = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      final userReferrals = userResponse['total_referrals'] as int;
      final userEarnings = (userResponse['total_earnings'] as num).toDouble();
      
      // Get all available achievements
      final achievementsResponse = await client
          .from('achievements')
          .select()
          .order('target_value');
      
      // Get user's unlocked achievements
      final userAchievementsResponse = await client
          .from('user_achievements')
          .select()
          .eq('user_id', userId);
      
      List<Achievement> achievements = [];
      
      for (var achievementData in achievementsResponse) {
        final achievementId = achievementData['id'] as String;
        final type = achievementData['type'] as String;
        final targetValue = achievementData['target_value'] as int;
        
        // Check if user has unlocked this achievement
        final userAchievementsList = userAchievementsResponse
            .where((ua) => ua['achievement_id'] == achievementId)
            .toList();
        final userAchievement = userAchievementsList.isNotEmpty ? userAchievementsList.first : null;
        
        // Calculate if achievement should be unlocked
        bool shouldBeUnlocked = false;
        switch (type) {
          case 'referrals':
            shouldBeUnlocked = userReferrals >= targetValue;
            break;
          case 'earnings':
            shouldBeUnlocked = userEarnings >= targetValue;
            break;
          case 'special':
            // Top 3 leaderboard - implement later
            shouldBeUnlocked = false;
            break;
        }
        
        final isUnlocked = userAchievement?['is_unlocked'] == true || shouldBeUnlocked;
        
        // Auto-unlock achievement if conditions are met but not yet unlocked
        if (shouldBeUnlocked && userAchievement == null) {
          await _unlockAchievement(userId, achievementId, userEarnings);
        }
        
        achievements.add(Achievement(
          id: achievementId,
          title: achievementData['title'] as String,
          description: achievementData['description'] as String? ?? '',
          icon: achievementData['icon'] as String? ?? '🏆',
          type: _parseAchievementType(type),
          targetValue: targetValue,
          rewardAmount: (achievementData['reward_amount'] as num?)?.toDouble() ?? 0.0,
          isUnlocked: isUnlocked,
          unlockedAt: userAchievement != null && userAchievement['unlocked_at'] != null 
              ? DateTime.parse(userAchievement['unlocked_at'] as String)
              : (shouldBeUnlocked ? DateTime.now() : null),
        ));
      }
      
      print('✅ Found ${achievements.length} achievements (${achievements.where((a) => a.isUnlocked).length} unlocked)');
      return achievements;
    } catch (e) {
      print('❌ Error getting achievements: $e');
      return [];
    }
  }

  static Future<void> updateAchievementProgress(String userId, String achievementId, int progress) async {
    try {
      // In production, update in Supabase
      print('Updated achievement $achievementId progress to $progress for user $userId');
    } catch (e) {
      print('Error updating achievement progress: $e');
    }
  }

  static Future<void> _unlockAchievement(String userId, String achievementId, double currentEarnings) async {
    try {
      print('🎉 Unlocking achievement $achievementId for user $userId');
      
      // Get achievement details
      final achievementResponse = await client
          .from('achievements')
          .select()
          .eq('id', achievementId)
          .single();
      
      final rewardAmount = (achievementResponse['reward_amount'] as num).toDouble();
      final title = achievementResponse['title'] as String;
      
      // Insert user achievement record
      await client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
        'is_unlocked': true,
        'unlocked_at': DateTime.now().toIso8601String(),
        'progress': 100,
      });
      
      // Add reward to user's earnings
      if (rewardAmount > 0) {
        await client
            .from('users')
            .update({
              'total_earnings': currentEarnings + rewardAmount,
            })
            .eq('id', userId);
        
        print('💰 Added \$${rewardAmount.toStringAsFixed(2)} reward for achievement: $title');
      }
      
      print('✅ Achievement unlocked successfully: $title');
    } catch (e) {
      print('❌ Error unlocking achievement: $e');
    }
  }

  // ==================== LEADERBOARD OPERATIONS ====================
  
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      print('📊 Getting leaderboard data...');
      
      // Get all users ordered by total_referrals (descending), then by total_earnings
      final response = await client
          .from('users')
          .select('id, email, first_name, last_name, referral_code, total_referrals, total_earnings, created_at')
          .order('total_referrals', ascending: false)
          .order('total_earnings', ascending: false)
          .order('created_at', ascending: true); // Earlier users win ties
      
      print('✅ Found ${response.length} users for leaderboard');
      
      // Add rank to each user
      final leaderboard = <Map<String, dynamic>>[];
      for (int i = 0; i < response.length; i++) {
        final user = Map<String, dynamic>.from(response[i]);
        user['rank'] = i + 1;
        user['full_name'] = '${user['first_name']} ${user['last_name']}';
        leaderboard.add(user);
      }
      
      // Award prizes to top 3 if they haven't been awarded yet
      await _awardLeaderboardPrizes(leaderboard);
      
      return leaderboard;
    } catch (e) {
      print('❌ Error getting leaderboard: $e');
      return [];
    }
  }
  
  static Future<void> _awardLeaderboardPrizes(List<Map<String, dynamic>> leaderboard) async {
    try {
      final prizes = [
        {'rank': 1, 'amount': 100.0, 'title': 'Campeão 🥇'},
        {'rank': 2, 'amount': 50.0, 'title': 'Vice-Campeão 🥈'},
        {'rank': 3, 'amount': 25.0, 'title': 'Terceiro Lugar 🥉'},
      ];
      
      for (final prize in prizes) {
        final userRank = prize['rank'] as int;
        if (leaderboard.length >= userRank) {
          final userIndex = userRank - 1;
          final user = leaderboard[userIndex];
          final userId = user['id'] as String;
          final prizeAmount = prize['amount'] as double;
          
          // Check if user already received this specific leaderboard prize
          final existingPrize = await client
              .from('user_achievements')
              .select()
              .eq('user_id', userId)
              .eq('achievement_id', 'leaderboard_${userRank}')
              .limit(1);
          
          if (existingPrize.isEmpty) {
            print('🏆 Awarding leaderboard prize to rank $userRank: ${user['full_name']}');
            
            // Create achievement record
            await client.from('user_achievements').insert({
              'user_id': userId,
              'achievement_id': 'leaderboard_${userRank}',
              'is_unlocked': true,
              'unlocked_at': DateTime.now().toIso8601String(),
              'progress': 100,
            });
            
            // Add prize money
            await client
                .from('users')
                .update({
                  'total_earnings': (user['total_earnings'] as num) + prizeAmount,
                })
                .eq('id', userId);
            
            print('💰 Added \$${prizeAmount.toStringAsFixed(0)} to ${user['full_name']} for ${prize['title']}');
          }
        }
      }
    } catch (e) {
      print('❌ Error awarding leaderboard prizes: $e');
    }
  }

  // ==================== ANALYTICS FOR AI AGENT ====================
  
  static Future<Map<String, dynamic>> getAnalyticsData(String userId, {bool isAdmin = false}) async {
    try {
      if (isAdmin) {
        // Admin gets global analytics
        return {
          'total_users': 150,
          'total_referrals': 450,
          'conversion_rate': 0.18,
          'top_performers': [
            {'name': 'João Silva', 'referrals': 12, 'earnings': 600.0},
            {'name': 'Maria Santos', 'referrals': 8, 'earnings': 400.0},
          ],
          'churn_risk_users': 15,
        };
      } else {
        // Regular user gets personal analytics
        return {
          'user_referrals': 3,
          'user_earnings': 150.0,
          'conversion_rate': 0.60,
          'days_since_registration': 30,
          'position_in_ranking': 25,
        };
      }
    } catch (e) {
      print('Error getting analytics: $e');
      return {};
    }
  }

  // ==================== HELPER METHODS ====================
  
  static Future<void> _processReferral(String referralCode, String newUserId) async {
    try {
      print('🎯 Processing referral for code: $referralCode');
      
      // Find the user who owns this referral code
      final referrerResponse = await client
          .from('users')
          .select()
          .eq('referral_code', referralCode)
          .limit(1);
      
      if (referrerResponse.isEmpty) {
        throw Exception('Invalid referral code: $referralCode');
      }
      
      final referrer = referrerResponse.first;
      final referrerId = referrer['id'] as String;
      
      print('✅ Found referrer: ${referrer['email']}');
      
      // Update referrer's stats
      await client
          .from('users')
          .update({
            'total_referrals': (referrer['total_referrals'] as int) + 1,
            'total_earnings': (referrer['total_earnings'] as num) + 50.0, // Referrer bonus
          })
          .eq('id', referrerId);
      
      print('✅ Updated referrer stats: +1 referral, +\$50 earnings');
      
    } catch (e) {
      print('❌ Error processing referral: $e');
      rethrow;
    }
  }
  
  static String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      List.generate(6, (index) => chars.codeUnitAt((random + index) % chars.length))
    );
  }
  
  static AchievementType _parseAchievementType(String type) {
    switch (type.toLowerCase()) {
      case 'referrals':
        return AchievementType.referrals;
      case 'earnings':
        return AchievementType.earnings;
      case 'streak':
        return AchievementType.streak;
      case 'special':
        return AchievementType.special;
      case 'account':
        return AchievementType.special; // Mapear 'account' para 'special'
      default:
        return AchievementType.referrals;
    }
  }
}