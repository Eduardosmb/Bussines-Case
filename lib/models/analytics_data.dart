class AIResponse {
  final String query;
  final String response;
  final List<String> insights;
  final List<String> suggestedQuestions;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  AIResponse({
    required this.query,
    required this.response,
    this.insights = const [],
    this.suggestedQuestions = const [],
    required this.timestamp,
    this.data,
  });
}

class ReferralAnalytics {
  final int totalClicks;
  final int totalRegistrations; 
  final double conversionRate;
  final int totalUsers;
  final int totalReferrals;
  final ROI roi;

  ReferralAnalytics({
    required this.totalClicks,
    required this.totalRegistrations,
    required this.conversionRate,
    this.totalUsers = 0,
    this.totalReferrals = 0,
    required this.roi,
  });
}

class ROI {
  final double roiPercentage;
  
  ROI({required this.roiPercentage});
}
