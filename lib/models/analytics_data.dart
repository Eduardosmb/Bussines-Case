import 'dart:math';

/// Analytics and insights data models for the AI Data Agent
class ReferralAnalytics {
  final int totalUsers;
  final int totalReferrals;
  final double totalEarnings;
  final double averageReferralsPerUser;
  final double conversionRate;
  final double averageEarningsPerUser;
  final List<UserPerformance> topPerformers;
  final List<ChurnRiskUser> churnRiskUsers;
  final ReferralROI roi;
  final GrowthForecast forecast;

  ReferralAnalytics({
    required this.totalUsers,
    required this.totalReferrals,
    required this.totalEarnings,
    required this.averageReferralsPerUser,
    required this.conversionRate,
    required this.averageEarningsPerUser,
    required this.topPerformers,
    required this.churnRiskUsers,
    required this.roi,
    required this.forecast,
  });
}

class UserPerformance {
  final String userId;
  final String userName;
  final String email;
  final int referrals;
  final double earnings;
  final double conversionRate;
  final DateTime lastActivity;
  final PerformanceRating rating;

  UserPerformance({
    required this.userId,
    required this.userName,
    required this.email,
    required this.referrals,
    required this.earnings,
    required this.conversionRate,
    required this.lastActivity,
    required this.rating,
  });
}

enum PerformanceRating { excellent, good, average, poor }

class ChurnRiskUser {
  final String userId;
  final String userName;
  final String email;
  final double churnRiskScore; // 0.0 to 1.0
  final List<String> riskFactors;
  final String recommendation;
  final DateTime lastActivity;

  ChurnRiskUser({
    required this.userId,
    required this.userName,
    required this.email,
    required this.churnRiskScore,
    required this.riskFactors,
    required this.recommendation,
    required this.lastActivity,
  });
}

class ReferralROI {
  final double totalInvestment;
  final double totalRevenue;
  final double roiPercentage;
  final double costPerAcquisition;
  final double lifetimeValue;
  final int paybackPeriodDays;

  ReferralROI({
    required this.totalInvestment,
    required this.totalRevenue,
    required this.roiPercentage,
    required this.costPerAcquisition,
    required this.lifetimeValue,
    required this.paybackPeriodDays,
  });
}

class GrowthForecast {
  final List<MonthlyForecast> monthlyPredictions;
  final double predictedGrowthRate;
  final int predictedNewUsers;
  final double predictedRevenue;
  final List<String> recommendations;

  GrowthForecast({
    required this.monthlyPredictions,
    required this.predictedGrowthRate,
    required this.predictedNewUsers,
    required this.predictedRevenue,
    required this.recommendations,
  });
}

class MonthlyForecast {
  final DateTime month;
  final int predictedUsers;
  final int predictedReferrals;
  final double predictedRevenue;
  final double confidence; // 0.0 to 1.0

  MonthlyForecast({
    required this.month,
    required this.predictedUsers,
    required this.predictedReferrals,
    required this.predictedRevenue,
    required this.confidence,
  });
}

/// Natural Language Query Response
class AIResponse {
  final String query;
  final String response;
  final List<String> insights;
  final Map<String, dynamic>? data;
  final List<String> suggestedQuestions;
  final DateTime timestamp;

  AIResponse({
    required this.query,
    required this.response,
    required this.insights,
    this.data,
    required this.suggestedQuestions,
    required this.timestamp,
  });
}

/// Performance insights for marketing strategies
class MarketingInsights {
  final String channelName;
  final double conversionRate;
  final double costPerAcquisition;
  final int totalReferrals;
  final String recommendation;
  final double impactScore; // 0.0 to 1.0

  MarketingInsights({
    required this.channelName,
    required this.conversionRate,
    required this.costPerAcquisition,
    required this.totalReferrals,
    required this.recommendation,
    required this.impactScore,
  });
}

/// Demographic insights
class DemographicInsights {
  final Map<String, int> ageGroups;
  final Map<String, int> locations;
  final Map<String, double> performanceByDemographic;
  final List<String> targetingRecommendations;

  DemographicInsights({
    required this.ageGroups,
    required this.locations,
    required this.performanceByDemographic,
    required this.targetingRecommendations,
  });
}

