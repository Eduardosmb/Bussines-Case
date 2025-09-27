import 'dart:math';
import '../models/analytics_data.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'referral_link_service.dart';
import 'openai_ai_service.dart';

/// AI Data Agent for CloudWalk Referral Program
/// Provides automated data collection, analysis, and insights
class AIDataAgent {
  static final Random _random = Random();
  
  /// Generate comprehensive referral analytics
  static Future<ReferralAnalytics> generateAnalytics() async {
    final authService = AuthService();
    final users = await authService.getAllUsers();
    
    // Get referral link analytics
    final linkAnalytics = await ReferralLinkService.getConversionAnalytics();
    
    // Calculate basic metrics
    final totalUsers = users.length;
    final totalReferrals = users.fold(0, (sum, user) => sum + user.totalReferrals);
    final totalEarnings = users.fold(0.0, (sum, user) => sum + user.totalEarnings);
    
    final averageReferralsPerUser = totalUsers > 0 ? totalReferrals / totalUsers : 0.0;
    final conversionRate = linkAnalytics['overallConversionRate'] ?? _calculateConversionRate(users);
    final averageEarningsPerUser = totalUsers > 0 ? totalEarnings / totalUsers : 0.0;
    
    // Generate insights
    final topPerformers = _getTopPerformers(users);
    final churnRiskUsers = _identifyChurnRisk(users);
    final roi = _calculateROI(users);
    final forecast = _generateForecast(users);
    
    return ReferralAnalytics(
      totalUsers: totalUsers,
      totalReferrals: totalReferrals,
      totalEarnings: totalEarnings,
      averageReferralsPerUser: averageReferralsPerUser,
      conversionRate: conversionRate,
      averageEarningsPerUser: averageEarningsPerUser,
      topPerformers: topPerformers,
      churnRiskUsers: churnRiskUsers,
      roi: roi,
      forecast: forecast,
    );
  }
  
  /// Process natural language queries using OpenAI GPT-4
  static Future<AIResponse> processQuery(String query) async {
    // Direct OpenAI processing - no fallback
    return await OpenAIService.processQuery(query);
  }
  
  /// Generate marketing recommendations
  static Future<List<String>> generateMarketingRecommendations() async {
    final analytics = await generateAnalytics();
    final recommendations = <String>[];
    
    // Performance-based recommendations
    if (analytics.conversionRate < 0.15) {
      recommendations.add("🎯 Improve referral incentives - current conversion rate (${(analytics.conversionRate * 100).toStringAsFixed(1)}%) is below industry average");
    }
    
    if (analytics.averageReferralsPerUser < 2) {
      recommendations.add("📈 Launch a referral competition to motivate top performers");
    }
    
    if (analytics.churnRiskUsers.length > analytics.totalUsers * 0.3) {
      recommendations.add("⚠️ Implement retention campaigns - ${analytics.churnRiskUsers.length} users at churn risk");
    }
    
    // ROI-based recommendations
    if (analytics.roi.roiPercentage < 200) {
      recommendations.add("💰 Optimize reward structure to improve ROI (currently ${analytics.roi.roiPercentage.toStringAsFixed(0)}%)");
    }
    
    // Growth recommendations
    if (analytics.forecast.predictedGrowthRate < 0.1) {
      recommendations.add("🚀 Launch viral marketing campaign to accelerate growth");
    }
    
    // Always include some strategic recommendations
    recommendations.addAll([
      "📱 Implement push notifications for referral milestones",
      "🎮 Add gamification elements like streaks and bonus rounds",
      "📊 Create personalized dashboards for top performers",
      "🤝 Partner with influencers to amplify referral reach",
    ]);
    
    return recommendations.take(5).toList();
  }
  
  /// Automated data cleaning and validation
  static Future<Map<String, dynamic>> cleanAndValidateData() async {
    final authService = AuthService();
    final users = await authService.getAllUsers();
    
    final issues = <String>[];
    final fixes = <String>[];
    
    // Check for data consistency
    final totalReferrals = users.fold(0, (sum, user) => sum + user.totalReferrals);
    final usersWithReferrals = users.where((user) => user.totalReferrals > 0).length;
    
    if (totalReferrals > users.length - 1) {
      issues.add("⚠️ Total referrals (${totalReferrals}) exceeds possible maximum (${users.length - 1})");
      fixes.add("🔧 Validate referral counting logic");
    }
    
    // Check earnings consistency
    for (final user in users) {
      final expectedEarnings = user.totalReferrals * 50.0; // $50 per referral
      if ((user.totalEarnings - expectedEarnings).abs() > 25) { // Allow for signup bonus
        issues.add("💰 User ${user.firstName} has inconsistent earnings");
        fixes.add("🔧 Recalculate earnings for ${user.firstName}");
      }
    }
    
    // Check for duplicate referral codes
    final codes = users.map((user) => user.referralCode).toList();
    final uniqueCodes = codes.toSet();
    if (codes.length != uniqueCodes.length) {
      issues.add("🔄 Duplicate referral codes detected");
      fixes.add("🔧 Generate new unique codes");
    }
    
    return {
      'issues': issues,
      'fixes': fixes,
      'dataQuality': issues.isEmpty ? 'Excellent' : issues.length < 3 ? 'Good' : 'Needs Attention',
      'totalUsers': users.length,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }
  
  // Private helper methods
  
  static double _calculateConversionRate(List<User> users) {
    if (users.isEmpty) return 0.0;
    final usersWithReferrals = users.where((user) => user.totalReferrals > 0).length;
    return usersWithReferrals / users.length;
  }
  
  static List<UserPerformance> _getTopPerformers(List<User> users) {
    final performers = users.map((user) {
      return UserPerformance(
        userId: user.id,
        userName: user.fullName,
        email: user.email,
        referrals: user.totalReferrals,
        earnings: user.totalEarnings,
        conversionRate: user.totalReferrals > 0 ? 0.8 : 0.0, // Simulated
        lastActivity: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        rating: _getPerformanceRating(user.totalReferrals),
      );
    }).toList();
    
    performers.sort((a, b) => b.referrals.compareTo(a.referrals));
    return performers.take(5).toList();
  }
  
  static PerformanceRating _getPerformanceRating(int referrals) {
    if (referrals >= 4) return PerformanceRating.excellent;
    if (referrals >= 2) return PerformanceRating.good;
    if (referrals >= 1) return PerformanceRating.average;
    return PerformanceRating.poor;
  }
  
  static List<ChurnRiskUser> _identifyChurnRisk(List<User> users) {
    return users.where((user) => user.totalReferrals == 0).map((user) {
      final riskScore = 0.3 + (_random.nextDouble() * 0.4); // 0.3-0.7 range
      final riskFactors = <String>[];
      
      if (user.totalReferrals == 0) riskFactors.add("No referrals made");
      if (user.totalEarnings <= 25) riskFactors.add("Low earnings");
      
      return ChurnRiskUser(
        userId: user.id,
        userName: user.fullName,
        email: user.email,
        churnRiskScore: riskScore,
        riskFactors: riskFactors,
        recommendation: "Send personalized referral tips and bonus incentives",
        lastActivity: DateTime.now().subtract(Duration(days: _random.nextInt(14))),
      );
    }).toList();
  }
  
  static ReferralROI _calculateROI(List<User> users) {
    final totalEarnings = users.fold(0.0, (sum, user) => sum + user.totalEarnings);
    final totalInvestment = totalEarnings; // Simplified: what we pay out is our investment
    final totalRevenue = totalEarnings * 2.5; // Assume each referred user generates 2.5x revenue
    
    return ReferralROI(
      totalInvestment: totalInvestment,
      totalRevenue: totalRevenue,
      roiPercentage: totalInvestment > 0 ? ((totalRevenue - totalInvestment) / totalInvestment) * 100 : 0,
      costPerAcquisition: users.isNotEmpty ? totalInvestment / users.length : 0,
      lifetimeValue: 150.0, // Simulated customer LTV
      paybackPeriodDays: 45, // Simulated
    );
  }
  
  static GrowthForecast _generateForecast(List<User> users) {
    final currentGrowthRate = 0.15; // 15% monthly growth
    final monthlyPredictions = <MonthlyForecast>[];
    
    for (int i = 1; i <= 6; i++) {
      final month = DateTime.now().add(Duration(days: 30 * i));
      final predictedUsers = (users.length * pow(1 + currentGrowthRate, i)).round();
      final predictedReferrals = (predictedUsers * 0.3).round(); // 30% make referrals
      final predictedRevenue = predictedReferrals * 50.0;
      
      monthlyPredictions.add(MonthlyForecast(
        month: month,
        predictedUsers: predictedUsers,
        predictedReferrals: predictedReferrals,
        predictedRevenue: predictedRevenue,
        confidence: 0.85 - (i * 0.1), // Decreasing confidence over time
      ));
    }
    
    return GrowthForecast(
      monthlyPredictions: monthlyPredictions,
      predictedGrowthRate: currentGrowthRate,
      predictedNewUsers: monthlyPredictions.first.predictedUsers - users.length,
      predictedRevenue: monthlyPredictions.fold(0.0, (sum, month) => sum + month.predictedRevenue),
      recommendations: [
        "Focus on improving conversion rate from current ${(_calculateConversionRate(users) * 100).toStringAsFixed(1)}%",
        "Implement seasonal campaigns to boost referral activity",
        "Target users with 0 referrals for activation campaigns",
      ],
    );
  }
  
  // Natural Language Processing helpers
  
  static bool _containsWords(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }
  
  static Future<AIResponse> _handlePerformanceQuery(String query) async {
    final analytics = await generateAnalytics();
    final topPerformer = analytics.topPerformers.first;
    
    return AIResponse(
      query: query,
      response: "Your top performer is ${topPerformer.userName} with ${topPerformer.referrals} referrals and \$${topPerformer.earnings.toStringAsFixed(2)} earned. The average user makes ${analytics.averageReferralsPerUser.toStringAsFixed(1)} referrals.",
      insights: [
        "Top 20% of users generate 80% of referrals",
        "Performance rating: ${topPerformer.rating.name}",
        "Conversion rate: ${(analytics.conversionRate * 100).toStringAsFixed(1)}%",
      ],
      data: {'topPerformers': analytics.topPerformers.take(3).toList()},
      suggestedQuestions: [
        "How can I improve my referral conversion rate?",
        "Who are the users at risk of churning?",
        "What's the ROI of our referral program?",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  static Future<AIResponse> _handleChurnQuery(String query) async {
    final analytics = await generateAnalytics();
    final churnUsers = analytics.churnRiskUsers;
    
    return AIResponse(
      query: query,
      response: "I've identified ${churnUsers.length} users at churn risk. These users have made 0 referrals and may need engagement. Average risk score is ${churnUsers.isNotEmpty ? (churnUsers.map((u) => u.churnRiskScore).reduce((a, b) => a + b) / churnUsers.length * 100).toStringAsFixed(1) : 0}%.",
      insights: [
        "Users with 0 referrals have higher churn probability",
        "Recommended action: Send personalized referral guides",
        "Consider bonus incentives for first referral",
      ],
      data: {'churnRiskUsers': churnUsers.take(5).toList()},
      suggestedQuestions: [
        "How can I reduce churn risk?",
        "What incentives work best for inactive users?",
        "Show me engagement strategies",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  static Future<AIResponse> _handleROIQuery(String query) async {
    final analytics = await generateAnalytics();
    final roi = analytics.roi;
    
    return AIResponse(
      query: query,
      response: "Your referral program ROI is ${roi.roiPercentage.toStringAsFixed(0)}%. You've invested \$${roi.totalInvestment.toStringAsFixed(2)} and generated \$${roi.totalRevenue.toStringAsFixed(2)} in revenue. Cost per acquisition is \$${roi.costPerAcquisition.toStringAsFixed(2)}.",
      insights: [
        "ROI above 200% indicates healthy program performance",
        "Payback period: ${roi.paybackPeriodDays} days",
        "Customer lifetime value: \$${roi.lifetimeValue}",
      ],
      data: {'roi': roi},
      suggestedQuestions: [
        "How can I improve ROI?",
        "What's the optimal reward amount?",
        "Show me cost optimization strategies",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  static Future<AIResponse> _handleForecastQuery(String query) async {
    final analytics = await generateAnalytics();
    final forecast = analytics.forecast;
    
    return AIResponse(
      query: query,
      response: "Based on current trends, I predict ${forecast.predictedNewUsers} new users next month with ${forecast.predictedGrowthRate * 100}% growth rate. Expected revenue: \$${forecast.predictedRevenue.toStringAsFixed(2)} over 6 months.",
      insights: [
        "Growth trend: ${forecast.predictedGrowthRate > 0.1 ? 'Accelerating' : 'Steady'}",
        "Confidence level: ${(forecast.monthlyPredictions.first.confidence * 100).toStringAsFixed(0)}%",
        "Seasonal factors may impact predictions",
      ],
      data: {'forecast': forecast},
      suggestedQuestions: [
        "What factors drive growth?",
        "How accurate are these predictions?",
        "Show me growth strategies",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  static Future<AIResponse> _handleConversionQuery(String query) async {
    final analytics = await generateAnalytics();
    
    return AIResponse(
      query: query,
      response: "Your referral conversion rate is ${(analytics.conversionRate * 100).toStringAsFixed(1)}%. This means ${(analytics.conversionRate * 100).toStringAsFixed(1)}% of users make at least one referral. Industry benchmark is typically 15-25%.",
      insights: [
        analytics.conversionRate >= 0.25 ? "Excellent conversion rate!" : "Room for improvement in conversion",
        "Top performers have 80%+ personal conversion rates",
        "Focus on first referral activation for new users",
      ],
      data: {'conversionRate': analytics.conversionRate},
      suggestedQuestions: [
        "How can I improve conversion rates?",
        "What motivates users to make their first referral?",
        "Show me conversion optimization strategies",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  static Future<AIResponse> _handleRecommendationQuery(String query) async {
    final recommendations = await generateMarketingRecommendations();
    
    return AIResponse(
      query: query,
      response: "Based on your current performance, here are my top recommendations: ${recommendations.take(3).join(', ')}",
      insights: [
        "Recommendations are based on real-time data analysis",
        "Prioritize actions with highest impact potential",
        "Monitor results and adjust strategies accordingly",
      ],
      data: {'recommendations': recommendations},
      suggestedQuestions: [
        "How do I implement these recommendations?",
        "What's the expected impact?",
        "Show me success metrics to track",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  static Future<AIResponse> _handleGenericQuery(String query) async {
    final analytics = await generateAnalytics();
    
    return AIResponse(
      query: query,
      response: "I can help you analyze your referral program! Currently you have ${analytics.totalUsers} users with ${analytics.totalReferrals} total referrals generating \$${analytics.totalEarnings.toStringAsFixed(2)}. What specific insights would you like?",
      insights: [
        "I can analyze performance, churn risk, ROI, and forecasts",
        "Ask me natural language questions about your data",
        "I provide actionable recommendations for growth",
      ],
      data: {'overview': analytics},
      suggestedQuestions: [
        "Who are my top performers?",
        "What's my referral program ROI?",
        "Show me growth predictions",
        "Which users might churn?",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  static Future<AIResponse> _handleFunnelQuery(String query) async {
    final funnelData = await ReferralLinkService.getFunnelAnalysis();
    final analytics = await ReferralLinkService.getConversionAnalytics();
    
    final totalDropOffs = analytics['totalDropOffs'] ?? 0;
    final avgConversion = funnelData.isNotEmpty 
      ? funnelData.map((f) => f.overallConversionRate).reduce((a, b) => a + b) / funnelData.length
      : 0.0;
    
    return AIResponse(
      query: query,
      response: "I've analyzed your conversion funnel. You have ${analytics['totalClicks']} total link clicks with ${analytics['totalRegistrations']} completed registrations. $totalDropOffs users clicked but didn't complete registration (${((totalDropOffs / (analytics['totalClicks'] as int)) * 100).toStringAsFixed(1)}% drop-off rate).",
      insights: [
        "Average conversion rate: ${(avgConversion * 100).toStringAsFixed(1)}%",
        "Main drop-off point: Between link click and registration start",
        "Optimization opportunity: Simplify registration process",
      ],
      data: {'funnelAnalysis': funnelData.take(3).toList()},
      suggestedQuestions: [
        "How can I reduce drop-off rates?",
        "Which links perform best?",
        "What causes registration abandonment?",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  static Future<AIResponse> _handleLinkTrackingQuery(String query) async {
    final analytics = await ReferralLinkService.getConversionAnalytics();
    final topLinks = analytics['topPerformingLinks'] as List? ?? [];
    
    return AIResponse(
      query: query,
      response: "I'm tracking ${analytics['totalLinks']} referral links with ${analytics['totalClicks']} total clicks and ${analytics['recentActivity']} clicks in the last 7 days. Top performing link has a ${topLinks.isNotEmpty ? (topLinks.first.conversionRate * 100).toStringAsFixed(1) : '0'}% conversion rate.",
      insights: [
        "Real-time click tracking is active",
        "${analytics['linksWithZeroConversions']} links have zero conversions",
        "Average clicks per link: ${(analytics['averageClicksPerLink'] as double).toStringAsFixed(1)}",
      ],
      data: {'linkAnalytics': analytics},
      suggestedQuestions: [
        "Which links need optimization?",
        "Show me conversion funnel analysis",
        "How can I improve link performance?",
      ],
      timestamp: DateTime.now(),
    );
  }
}
