import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String referralCode;
  final String? referredByCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isActive;
  final UserStats stats;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.referralCode,
    this.referredByCode,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.isActive = true,
    required this.stats,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => fullName.trim().isEmpty ? email : fullName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'referralCode': referralCode,
      'referredByCode': referredByCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmailVerified': isEmailVerified,
      'isActive': isActive,
      'stats': stats.toJson(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      referralCode: json['referralCode'] ?? '',
      referredByCode: json['referredByCode'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      stats: UserStats.fromJson(json['stats'] ?? {}),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    String? referralCode,
    String? referredByCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isActive,
    UserStats? stats,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      referralCode: referralCode ?? this.referralCode,
      referredByCode: referredByCode ?? this.referredByCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      stats: stats ?? this.stats,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName)';
  }
}

class UserStats {
  final int totalReferrals;
  final int successfulReferrals;
  final double totalEarnings;
  final double pendingEarnings;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastReferralDate;

  UserStats({
    this.totalReferrals = 0,
    this.successfulReferrals = 0,
    this.totalEarnings = 0.0,
    this.pendingEarnings = 0.0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReferralDate,
  });

  double get conversionRate {
    if (totalReferrals == 0) return 0.0;
    return (successfulReferrals / totalReferrals) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReferrals': totalReferrals,
      'successfulReferrals': successfulReferrals,
      'totalEarnings': totalEarnings,
      'pendingEarnings': pendingEarnings,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastReferralDate': lastReferralDate != null 
          ? Timestamp.fromDate(lastReferralDate!) 
          : null,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalReferrals: json['totalReferrals'] ?? 0,
      successfulReferrals: json['successfulReferrals'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      pendingEarnings: (json['pendingEarnings'] ?? 0.0).toDouble(),
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastReferralDate: (json['lastReferralDate'] as Timestamp?)?.toDate(),
    );
  }

  UserStats copyWith({
    int? totalReferrals,
    int? successfulReferrals,
    double? totalEarnings,
    double? pendingEarnings,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReferralDate,
  }) {
    return UserStats(
      totalReferrals: totalReferrals ?? this.totalReferrals,
      successfulReferrals: successfulReferrals ?? this.successfulReferrals,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReferralDate: lastReferralDate ?? this.lastReferralDate,
    );
  }
}
