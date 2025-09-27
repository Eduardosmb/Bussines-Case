import 'dart:math';

/// Referral link tracking model
class ReferralLink {
  final String id;
  final String userId;
  final String userName;
  final String linkCode; // Short code for the link
  final String fullUrl;
  final DateTime createdAt;
  final int clickCount;
  final int registrationCount;
  final List<ReferralClick> clicks;
  final List<String> completedRegistrations;

  ReferralLink({
    required this.id,
    required this.userId,
    required this.userName,
    required this.linkCode,
    required this.fullUrl,
    required this.createdAt,
    this.clickCount = 0,
    this.registrationCount = 0,
    this.clicks = const [],
    this.completedRegistrations = const [],
  });

  double get conversionRate {
    if (clickCount == 0) return 0.0;
    return registrationCount / clickCount;
  }

  int get abandonedUsers => clickCount - registrationCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'linkCode': linkCode,
      'fullUrl': fullUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'clickCount': clickCount,
      'registrationCount': registrationCount,
      'clicks': clicks.map((c) => c.toJson()).toList(),
      'completedRegistrations': completedRegistrations,
    };
  }

  factory ReferralLink.fromJson(Map<String, dynamic> json) {
    return ReferralLink(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      linkCode: json['linkCode'],
      fullUrl: json['fullUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      clickCount: json['clickCount'] ?? 0,
      registrationCount: json['registrationCount'] ?? 0,
      clicks: (json['clicks'] as List?)
          ?.map((c) => ReferralClick.fromJson(c))
          .toList() ?? [],
      completedRegistrations: List<String>.from(json['completedRegistrations'] ?? []),
    );
  }

  ReferralLink copyWith({
    String? id,
    String? userId,
    String? userName,
    String? linkCode,
    String? fullUrl,
    DateTime? createdAt,
    int? clickCount,
    int? registrationCount,
    List<ReferralClick>? clicks,
    List<String>? completedRegistrations,
  }) {
    return ReferralLink(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      linkCode: linkCode ?? this.linkCode,
      fullUrl: fullUrl ?? this.fullUrl,
      createdAt: createdAt ?? this.createdAt,
      clickCount: clickCount ?? this.clickCount,
      registrationCount: registrationCount ?? this.registrationCount,
      clicks: clicks ?? this.clicks,
      completedRegistrations: completedRegistrations ?? this.completedRegistrations,
    );
  }
}

/// Individual click tracking
class ReferralClick {
  final String id;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;
  final bool completedRegistration;
  final String? registeredEmail;

  ReferralClick({
    required this.id,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
    this.completedRegistration = false,
    this.registeredEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'completedRegistration': completedRegistration,
      'registeredEmail': registeredEmail,
    };
  }

  factory ReferralClick.fromJson(Map<String, dynamic> json) {
    return ReferralClick(
      id: json['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      completedRegistration: json['completedRegistration'] ?? false,
      registeredEmail: json['registeredEmail'],
    );
  }
}

/// Admin user model
class AdminUser {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime lastLogin;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.createdAt,
    required this.lastLogin,
  });

  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == AdminRole.superAdmin;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString(),
      'permissions': permissions,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLogin': lastLogin.millisecondsSinceEpoch,
    };
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: AdminRole.values.firstWhere(
        (r) => r.toString() == json['role'],
        orElse: () => AdminRole.viewer,
      ),
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastLogin: DateTime.fromMillisecondsSinceEpoch(json['lastLogin']),
    );
  }
}

enum AdminRole {
  superAdmin, // Full access
  manager,    // Most analytics, no user management
  analyst,    // Analytics only
  viewer,     // Read-only
}

/// Conversion funnel tracking
class ConversionFunnel {
  final String referralLinkId;
  final int totalClicks;
  final int startedRegistration;
  final int completedRegistration;
  final DateTime analysisDate;

  ConversionFunnel({
    required this.referralLinkId,
    required this.totalClicks,
    required this.startedRegistration,
    required this.completedRegistration,
    required this.analysisDate,
  });

  double get clickToStartRate {
    if (totalClicks == 0) return 0.0;
    return startedRegistration / totalClicks;
  }

  double get startToCompleteRate {
    if (startedRegistration == 0) return 0.0;
    return completedRegistration / startedRegistration;
  }

  double get overallConversionRate {
    if (totalClicks == 0) return 0.0;
    return completedRegistration / totalClicks;
  }

  int get dropOffAfterClick => totalClicks - startedRegistration;
  int get dropOffDuringRegistration => startedRegistration - completedRegistration;
}

