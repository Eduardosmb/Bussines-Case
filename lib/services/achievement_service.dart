import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/user.dart';

class AchievementService {
  static const String _achievementsKey = 'user_achievements';
  static const String _leaderboardKey = 'leaderboard_cache';

  // Predefined achievements
  static final List<Achievement> _defaultAchievements = [
    Achievement(
      id: 'first_referral',
      title: '🎯 First Success',
      description: 'Make your first referral',
      icon: '🎯',
      targetValue: 1,
      rewardAmount: 10.0,
      type: AchievementType.referrals,
    ),
    Achievement(
      id: 'five_referrals',
      title: '🔥 Network Builder',
      description: 'Refer 5 people',
      icon: '🔥',
      targetValue: 5,
      rewardAmount: 25.0,
      type: AchievementType.referrals,
    ),
    Achievement(
      id: 'ten_referrals',
      title: '💪 Influencer',
      description: 'Refer 10 people',
      icon: '💪',
      targetValue: 10,
      rewardAmount: 50.0,
      type: AchievementType.referrals,
    ),
    Achievement(
      id: 'twenty_referrals',
      title: '👑 Referral King',
      description: 'Refer 20 people',
      icon: '👑',
      targetValue: 20,
      rewardAmount: 100.0,
      type: AchievementType.referrals,
    ),
    Achievement(
      id: 'first_hundred',
      title: '💰 First \$100',
      description: 'Earn your first \$100',
      icon: '💰',
      targetValue: 100,
      rewardAmount: 20.0,
      type: AchievementType.earnings,
    ),
    Achievement(
      id: 'five_hundred',
      title: '💎 High Earner',
      description: 'Earn \$500 total',
      icon: '💎',
      targetValue: 500,
      rewardAmount: 50.0,
      type: AchievementType.earnings,
    ),
    Achievement(
      id: 'top_three',
      title: '🏆 Leaderboard Elite',
      description: 'Reach top 3 on leaderboard',
      icon: '🏆',
      targetValue: 3,
      rewardAmount: 75.0,
      type: AchievementType.special,
    ),
  ];

  // Get user achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString('${_achievementsKey}_$userId');
    
    if (achievementsJson == null) {
      // Return default achievements for new users
      return _defaultAchievements;
    }

    final List<dynamic> achievementsList = jsonDecode(achievementsJson);
    return achievementsList.map((json) => Achievement.fromJson(json)).toList();
  }

  // Save user achievements
  Future<void> saveUserAchievements(String userId, List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = jsonEncode(achievements.map((a) => a.toJson()).toList());
    await prefs.setString('${_achievementsKey}_$userId', achievementsJson);
  }

  // Check and unlock new achievements
  Future<List<Achievement>> checkAndUnlockAchievements(User user) async {
    final achievements = await getUserAchievements(user.id);
    final newlyUnlocked = <Achievement>[];

    for (int i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      
      if (!achievement.isUnlocked) {
        bool shouldUnlock = false;
        
        switch (achievement.type) {
          case AchievementType.referrals:
            shouldUnlock = user.totalReferrals >= achievement.targetValue;
            break;
          case AchievementType.earnings:
            shouldUnlock = user.totalEarnings >= achievement.targetValue;
            break;
          case AchievementType.special:
            // Check leaderboard position for special achievements
            if (achievement.id == 'top_three') {
              final rank = await getUserLeaderboardRank(user.id);
              shouldUnlock = rank <= 3 && rank > 0;
            }
            break;
          case AchievementType.streak:
            // Implement streak logic if needed
            break;
        }

        if (shouldUnlock) {
          achievements[i] = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          newlyUnlocked.add(achievements[i]);
        }
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await saveUserAchievements(user.id, achievements);
    }

    return newlyUnlocked;
  }

  // Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard() async {
    // This would typically fetch from all users
    // For now, we'll simulate this with cached data
    final prefs = await SharedPreferences.getInstance();
    final leaderboardJson = prefs.getString(_leaderboardKey);
    
    if (leaderboardJson != null) {
      final List<dynamic> leaderboardList = jsonDecode(leaderboardJson);
      return leaderboardList.map((json) => LeaderboardEntry(
        userId: json['userId'],
        userName: json['userName'],
        email: json['email'],
        totalReferrals: json['totalReferrals'],
        totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
        rank: json['rank'],
        referralCode: json['referralCode'],
      )).toList();
    }

    return [];
  }

  // Update leaderboard
  Future<void> updateLeaderboard(List<User> allUsers) async {
    // Sort users by referrals (primary) and earnings (secondary)
    final sortedUsers = List<User>.from(allUsers);
    sortedUsers.sort((a, b) {
      if (a.totalReferrals != b.totalReferrals) {
        return b.totalReferrals.compareTo(a.totalReferrals);
      }
      return b.totalEarnings.compareTo(a.totalEarnings);
    });

    final leaderboard = sortedUsers
        .asMap()
        .entries
        .map((entry) => LeaderboardEntry.fromUser(entry.value, entry.key + 1))
        .toList();

    final prefs = await SharedPreferences.getInstance();
    final leaderboardJson = jsonEncode(leaderboard.map((entry) => {
      'userId': entry.userId,
      'userName': entry.userName,
      'email': entry.email,
      'totalReferrals': entry.totalReferrals,
      'totalEarnings': entry.totalEarnings,
      'rank': entry.rank,
      'referralCode': entry.referralCode,
    }).toList());
    
    await prefs.setString(_leaderboardKey, leaderboardJson);
  }

  // Get user's leaderboard rank
  Future<int> getUserLeaderboardRank(String userId) async {
    final leaderboard = await getLeaderboard();
    final userEntry = leaderboard.firstWhere(
      (entry) => entry.userId == userId,
      orElse: () => LeaderboardEntry(
        userId: userId,
        userName: '',
        email: '',
        totalReferrals: 0,
        totalEarnings: 0.0,
        rank: 0,
        referralCode: '',
      ),
    );
    return userEntry.rank;
  }

  // Get leaderboard prizes
  Map<int, double> getLeaderboardPrizes() {
    return {
      1: 1000.0, // First place: $1000
      2: 500.0,  // Second place: $500
      3: 250.0,  // Third place: $250
    };
  }

  // Check if leaderboard competition is active
  bool isLeaderboardCompetitionActive() {
    // You can implement time-based competitions here
    return true;
  }

  // Get achievement progress
  double getAchievementProgress(Achievement achievement, User user) {
    switch (achievement.type) {
      case AchievementType.referrals:
        return (user.totalReferrals / achievement.targetValue).clamp(0.0, 1.0);
      case AchievementType.earnings:
        return (user.totalEarnings / achievement.targetValue).clamp(0.0, 1.0);
      case AchievementType.special:
      case AchievementType.streak:
        return achievement.isUnlocked ? 1.0 : 0.0;
    }
  }

  // Get total achievement rewards earned
  Future<double> getTotalAchievementRewards(String userId) async {
    final achievements = await getUserAchievements(userId);
    return achievements
        .where((a) => a.isUnlocked)
        .fold<double>(0.0, (sum, a) => sum + a.rewardAmount);
  }
}
