import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import '../models/analytics_data.dart';
import 'auth_service.dart';
import 'referral_link_service.dart';
import 'achievement_service.dart';
import 'config_service.dart';

class OpenAIService {
  static void initialize(String apiKey) {
    OpenAI.apiKey = apiKey;
    // OpenAI.organization = "YOUR_ORG_ID"; // Optional
  }
  
  /// Process natural language queries using OpenAI GPT-4
  static Future<AIResponse> processQuery(String userQuery) async {
    try {
      // Initialize OpenAI with saved API key
      final apiKey = await ConfigService.getOpenAIApiKey();
      if (apiKey != null) {
        initialize(apiKey);
      } else {
        throw Exception('No API key configured');
      }
      
      // First, gather all the data that the AI might need
      final contextData = await _gatherContextData();
      
      // Create a comprehensive system prompt
      final systemPrompt = _buildSystemPrompt(contextData);
      
      // Call OpenAI API
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4", 
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(userQuery),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
        temperature: 0.7,
        maxTokens: 1000,
      );
      
      final aiResponse = chatCompletion.choices.first.message.content?.first.text ?? 
                        "Sorry, I couldn't process your query.";
      
      // Parse the AI response and extract insights and suggestions
      final parsedResponse = _parseAIResponse(aiResponse, userQuery);
      
      return AIResponse(
        query: userQuery,
        response: parsedResponse['response'],
        insights: List<String>.from(parsedResponse['insights'] ?? []),
        data: contextData,
        suggestedQuestions: List<String>.from(parsedResponse['suggestedQuestions'] ?? []),
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      print('OpenAI API Error: $e');
      // Fallback to local analysis if API fails
      return _fallbackResponse(userQuery);
    }
  }
  
  /// Gather all relevant data for the AI context
  static Future<Map<String, dynamic>> _gatherContextData() async {
    try {
      // Get user data
      final authService = AuthService();
      final users = await authService.getAllUsers();
      
      // Get referral analytics
      final linkAnalytics = await ReferralLinkService.getConversionAnalytics();
      final funnelData = await ReferralLinkService.getFunnelAnalysis();
      
      // Get achievement data
      final achievementService = AchievementService();
      final leaderboard = await achievementService.getLeaderboard();
      
      // Calculate key metrics
      final totalUsers = users.length;
      final totalReferrals = users.fold(0, (sum, user) => sum + user.totalReferrals);
      final totalEarnings = users.fold(0.0, (sum, user) => sum + user.totalEarnings);
      final averageReferralsPerUser = totalUsers > 0 ? totalReferrals / totalUsers : 0.0;
      
      // Top performers
      final sortedUsers = [...users];
      sortedUsers.sort((a, b) => b.totalReferrals.compareTo(a.totalReferrals));
      final topPerformers = sortedUsers.take(5).map((user) => {
        'name': user.fullName,
        'email': user.email,
        'referrals': user.totalReferrals,
        'earnings': user.totalEarnings,
      }).toList();
      
      // Users at risk (no referrals)
      final churnRiskUsers = users.where((user) => user.totalReferrals == 0).map((user) => {
        'name': user.fullName,
        'email': user.email,
        'earnings': user.totalEarnings,
      }).toList();
      
      return {
        'summary': {
          'totalUsers': totalUsers,
          'totalReferrals': totalReferrals,
          'totalEarnings': totalEarnings,
          'averageReferralsPerUser': averageReferralsPerUser,
          'conversionRate': linkAnalytics['overallConversionRate'] ?? 0.0,
        },
        'linkAnalytics': {
          'totalClicks': linkAnalytics['totalClicks'] ?? 0,
          'totalRegistrations': linkAnalytics['totalRegistrations'] ?? 0,
          'totalDropOffs': linkAnalytics['totalDropOffs'] ?? 0,
          'averageClicksPerLink': linkAnalytics['averageClicksPerLink'] ?? 0.0,
          'linksWithZeroConversions': linkAnalytics['linksWithZeroConversions'] ?? 0,
        },
        'topPerformers': topPerformers,
        'churnRiskUsers': churnRiskUsers,
        'leaderboard': leaderboard.take(5).map((entry) => {
          'name': entry.userName,
          'referrals': entry.totalReferrals,
          'earnings': entry.totalEarnings,
        }).toList(),
        'funnelData': funnelData.take(3).map((funnel) => {
          'linkId': funnel.referralLinkId,
          'totalClicks': funnel.totalClicks,
          'startedRegistration': funnel.startedRegistration,
          'completedRegistration': funnel.completedRegistration,
          'conversionRate': funnel.overallConversionRate,
          'dropOffAfterClick': funnel.dropOffAfterClick,
          'dropOffDuringRegistration': funnel.dropOffDuringRegistration,
        }).toList(),
      };
    } catch (e) {
      print('Error gathering context data: $e');
      return {};
    }
  }
  
  /// Build comprehensive system prompt for the AI
  static String _buildSystemPrompt(Map<String, dynamic> contextData) {
    return '''
You are an AI Data Agent for CloudWalk's member-get-member referral program. You are an expert business analyst with deep knowledge of referral marketing, conversion optimization, and growth strategies.

CURRENT DATA CONTEXT:
${jsonEncode(contextData)}

YOUR ROLE:
- Analyze referral program performance using the provided data
- Provide actionable insights and recommendations
- Answer questions about user behavior, conversion rates, churn risk, and growth opportunities
- Suggest specific strategies to improve the referral program

RESPONSE FORMAT:
Always provide responses in a conversational, helpful tone. Include specific numbers and percentages from the data when relevant. Focus on actionable insights rather than just reporting numbers.

CAPABILITIES:
- Performance analysis (top performers, conversion rates, ROI)
- Churn risk assessment (users likely to leave, retention strategies)
- Conversion funnel analysis (drop-off points, optimization opportunities)
- Growth forecasting and recommendations
- Marketing strategy suggestions
- Competitive benchmarking insights

Remember: You are analyzing a Brazilian fintech company (CloudWalk) that offers the Infinity Pay product. Be culturally relevant and provide insights that make sense for the Brazilian market.

Answer the user's question based on the provided data context.
''';
  }
  
  /// Parse AI response to extract structured information
  static Map<String, dynamic> _parseAIResponse(String aiResponse, String originalQuery) {
    // Simple parsing - in production you might want more sophisticated parsing
    final response = aiResponse.trim();
    
    // Extract insights (look for bullet points or numbered lists)
    final insights = <String>[];
    final lines = response.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
        insights.add(trimmed.substring(1).trim());
      } else if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
        insights.add(trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), ''));
      }
    }
    
    // Generate contextual follow-up questions based on the query
    final suggestedQuestions = _generateSuggestedQuestions(originalQuery);
    
    return {
      'response': response,
      'insights': insights.take(5).toList(), // Limit to 5 insights
      'suggestedQuestions': suggestedQuestions,
    };
  }
  
  /// Generate contextual follow-up questions
  static List<String> _generateSuggestedQuestions(String originalQuery) {
    final query = originalQuery.toLowerCase();
    
    if (query.contains('performance') || query.contains('top')) {
      return [
        "How can I improve underperforming users?",
        "What motivates top performers?",
        "Show me conversion rate analysis",
      ];
    } else if (query.contains('churn') || query.contains('risk')) {
      return [
        "What retention strategies work best?",
        "How can I re-engage inactive users?",
        "Show me user behavior patterns",
      ];
    } else if (query.contains('conversion') || query.contains('funnel')) {
      return [
        "Where do most users drop off?",
        "How can I improve conversion rates?",
        "What's the optimal referral process?",
      ];
    } else if (query.contains('growth') || query.contains('forecast')) {
      return [
        "What growth strategies should I prioritize?",
        "How accurate are these predictions?",
        "Show me market opportunities",
      ];
    } else {
      return [
        "Analyze my top performers",
        "Show me churn risk analysis",
        "What's my conversion funnel like?",
        "Give me growth recommendations",
      ];
    }
  }
  
  /// Fallback response when OpenAI API is unavailable
  static AIResponse _fallbackResponse(String query) {
    return AIResponse(
      query: query,
      response: "I'm temporarily unable to access the AI model. Please check your internet connection or API configuration. You can still view your analytics in the dashboard.",
      insights: [
        "API connection issue detected",
        "Local analytics are still available",
        "Try again in a few moments",
      ],
      data: {},
      suggestedQuestions: [
        "Show me the analytics dashboard",
        "View conversion funnel analysis",
        "Check recent activity",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  /// Generate marketing recommendations using AI
  static Future<List<String>> generateAIRecommendations() async {
    try {
      final contextData = await _gatherContextData();
      
      final prompt = '''
Based on this referral program data, provide 5 specific, actionable marketing recommendations:

${jsonEncode(contextData)}

Focus on:
1. Improving conversion rates
2. Reducing churn
3. Increasing referral activity
4. Optimizing user experience
5. Growth strategies for the Brazilian market

Format as a simple list of recommendations.
''';
      
      final completion = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
        temperature: 0.8,
        maxTokens: 500,
      );
      
      final response = completion.choices.first.message.content?.first.text ?? '';
      
      // Parse recommendations from the response
      final recommendations = <String>[];
      final lines = response.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && (trimmed.startsWith('•') || trimmed.startsWith('-') || 
            trimmed.startsWith('*') || RegExp(r'^\d+\.').hasMatch(trimmed))) {
          String rec = trimmed.replaceFirst(RegExp(r'^[•\-*\d+\.\s]+'), '');
          if (rec.isNotEmpty) {
            recommendations.add(rec);
          }
        }
      }
      
      return recommendations.take(5).toList();
      
    } catch (e) {
      print('AI Recommendations Error: $e');
      // Fallback recommendations
      return [
        "🎯 Implement personalized onboarding for new users",
        "📱 Send push notifications for referral milestones", 
        "🎮 Add gamification with weekly challenges",
        "💰 Test different reward amounts and structures",
        "📊 Create detailed user journey analytics",
      ];
    }
  }
}
