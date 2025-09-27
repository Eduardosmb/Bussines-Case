class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String referralCode;
  final DateTime createdAt;
  final int totalReferrals;
  final double totalEarnings;
  final bool isAdmin;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.referralCode,
    required this.createdAt,
    this.totalReferrals = 0,
    this.totalEarnings = 0.0,
    this.isAdmin = false,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'referralCode': referralCode,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'totalReferrals': totalReferrals,
      'totalEarnings': totalEarnings,
      'isAdmin': isAdmin,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      referralCode: json['referralCode'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      totalReferrals: json['totalReferrals'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? referralCode,
    DateTime? createdAt,
    int? totalReferrals,
    double? totalEarnings,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      referralCode: referralCode ?? this.referralCode,
      createdAt: createdAt ?? this.createdAt,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
