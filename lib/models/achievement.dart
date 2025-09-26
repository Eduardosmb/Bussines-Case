import 'user.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int targetValue;
  final double rewardAmount;
  final AchievementType type;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.rewardAmount,
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'targetValue': targetValue,
      'rewardAmount': rewardAmount,
      'type': type.toString(),
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      targetValue: json['targetValue'],
      rewardAmount: (json['rewardAmount'] ?? 0.0).toDouble(),
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.referrals,
      ),
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
          : null,
    );
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? targetValue,
    double? rewardAmount,
    AchievementType? type,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

enum AchievementType {
  referrals,
  earnings,
  streak,
  special,
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String email;
  final int totalReferrals;
  final double totalEarnings;
  final int rank;
  final String referralCode;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.email,
    required this.totalReferrals,
    required this.totalEarnings,
    required this.rank,
    required this.referralCode,
  });

  factory LeaderboardEntry.fromUser(User user, int rank) {
    return LeaderboardEntry(
      userId: user.id,
      userName: user.fullName,
      email: user.email,
      totalReferrals: user.totalReferrals,
      totalEarnings: user.totalEarnings,
      rank: rank,
      referralCode: user.referralCode,
    );
  }
}
