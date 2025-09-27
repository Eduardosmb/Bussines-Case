import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analytics_data.dart';
import 'supabase_service.dart';

class OpenAIService {
  static void initialize(String apiKey) {
    OpenAI.apiKey = apiKey;
    // OpenAI.organization = "YOUR_ORG_ID"; // Optional
  }
  
  /// Process natural language queries using OpenAI GPT-4
  static Future<AIResponse> processQuery(String userQuery) async {
    try {
      // Load API key from .env file
      await dotenv.load(fileName: '.env');
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OPENAI_API_KEY not found in .env file');
      }
      
      initialize(apiKey);
      
      // First, gather all the data that the AI might need, including current user data
      final contextData = await _gatherContextDataWithUser();
      
      // Create a comprehensive system prompt with CloudWalk context
      final systemPrompt = '''
You are CloudWalk's AI Assistant. Your role is to help users understand their referral performance, achievements, and general platform features.

ABOUT CLOUDWALK & INFINITY PAY:

🏢 CLOUDWALK:
CloudWalk is a Brazilian fintech founded in 2017, leader in digital payments and blockchain solutions in Brazil. The company offers complete payment solutions for merchants of all sizes.

💳 TAP TO PAY:
- Near Field Communication (NFC) payment technology
- Accepts contactless cards, Apple Pay, Google Pay, Samsung Pay
- Secure and fast transactions without card insertion
- Integration with CloudWalk payment terminals

⛓️ BLOCKCHAIN STRATUS:
- CloudWalk's proprietary blockchain platform
- High-performance network for financial transactions
- Smart contracts and DeFi support
- Web3 infrastructure for Brazil
- Processing thousands of transactions per second

🏦 INFINITY PAY ECOSYSTEM:
- Infinity Pay: Digital wallet and payment solution
- Infinity Bank: Complete digital bank
- Infinity Cash: Cashback and rewards program
- Infinity Card: Credit and debit cards

💼 BUSINESS SOLUTIONS:
- Advanced payment terminals
- Online payment gateway
- E-commerce APIs
- White label solutions
- Real-time analytics and reporting

🌟 KEY DIFFERENTIALS:
- Competitive rates in Brazilian market
- Receivables advancement
- National blockchain technology
- 24/7 support
- Integration with major Brazilian e-commerces

🎯 REFERRAL PROGRAM:
- Referral system for CloudWalk users
- Earnings for successful referrals
- Achievements and rewards
- Top performers leaderboard

CURRENT USER DATA (You ALREADY HAVE this information - don't ask for it):
${_buildUserSpecificContext(contextData)}

OVERALL PLATFORM DATA:
${_buildPlatformContext(contextData)}

GUIDELINES:
- Always respond in English
- Be friendly and encouraging
- You ALREADY HAVE all the user's data above - never ask for it
- Provide specific insights based on the user's actual performance data
- Use emojis to make responses engaging
- Focus on CloudWalk, Infinity Pay, blockchain Stratus, and referral program
- Give actionable recommendations based on their current stats
- If asked about unrelated topics, politely redirect to CloudWalk/Infinity Pay
- IMPORTANT: Use the EXACT numbers from the USER'S CURRENT PERFORMANCE section above
''';
      
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
  
  /// Gather all relevant data for the AI context including current user
  static Future<Map<String, dynamic>> _gatherContextDataWithUser() async {
    try {
      // Get CURRENT USER data using SupabaseService static methods
      final currentUser = await SupabaseService.getCurrentUser();
      
      // Get user-specific achievements as Map objects
      final userAchievements = currentUser != null 
          ? (await SupabaseService.getUserAchievements(currentUser.id)).map((achievement) => achievement.toJson()).toList()
          : <Map<String, dynamic>>[];
      
      // Get leaderboard for platform stats
      final leaderboard = await SupabaseService.getLeaderboard();
      
      return {
        'currentUser': currentUser?.toJson(), // Convert User object to Map
        'userAchievements': userAchievements,
        'totalUsers': leaderboard.length,
        'totalReferrals': leaderboard.fold<int>(0, (sum, user) => sum + (user['total_referrals'] as int? ?? 0)),
        'totalEarnings': leaderboard.fold<double>(0.0, (sum, user) => sum + (user['total_earnings'] as double? ?? 0.0)),
        'leaderboard': leaderboard.take(5).toList(), // Already Map objects
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
      final contextData = await _gatherContextDataWithUser();
      
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

  /// Build user-specific context for AI
  static String _buildUserSpecificContext(Map<String, dynamic> contextData) {
    final currentUser = contextData['currentUser'];
    final userAchievements = contextData['userAchievements'] as List<dynamic>? ?? [];
    
    if (currentUser == null) {
      return 'User not logged in or data not available.';
    }
    
    final daysSinceJoined = DateTime.now().difference(
      DateTime.parse(currentUser['created_at'] ?? DateTime.now().toIso8601String())
    ).inDays;
    
    final unlockedAchievements = userAchievements.where((a) => a['isUnlocked'] == true).toList();
    
    final totalReferrals = currentUser['totalReferrals'] ?? currentUser['total_referrals'] ?? 0;
    final totalEarnings = currentUser['totalEarnings'] ?? currentUser['total_earnings'] ?? 0.0;
    final firstName = currentUser['firstName'] ?? currentUser['first_name'] ?? 'User';
    final lastName = currentUser['lastName'] ?? currentUser['last_name'] ?? '';
    final referralCode = currentUser['referralCode'] ?? currentUser['referral_code'] ?? 'Not available';
    
    return '''
USER'S CURRENT PERFORMANCE (You ALREADY have this data - use it in your response):
• Name: $firstName $lastName
• Email: ${currentUser['email']} 
• Days on platform: $daysSinceJoined days
• Total referrals made: $totalReferrals
• Total earnings: \$${totalEarnings.toStringAsFixed(2)}
• Referral code: $referralCode
• Achievements unlocked: ${unlockedAchievements.length}/${userAchievements.length}
• Member since: ${currentUser['created_at']}
• Performance level: ${_getPerformanceLevel(totalReferrals)}
''';
  }

  /// Get performance level based on referrals
  static String _getPerformanceLevel(int referrals) {
    if (referrals >= 30) return 'Gold Influencer 🏆';
    if (referrals >= 15) return 'Silver Influencer 🥈';
    if (referrals >= 5) return 'Bronze Influencer 🥉';
    if (referrals >= 1) return 'Active Member ⭐';
    return 'New Member 🌱';
  }

  /// Build platform context for AI
  static String _buildPlatformContext(Map<String, dynamic> contextData) {
    final totalUsers = contextData['totalUsers'] ?? 0;
    final leaderboard = contextData['leaderboard'] as List<dynamic>? ?? [];
    
    return '''
PLATFORM STATISTICS:
• Total users on platform: $totalUsers
• Top 3 performers: ${leaderboard.take(3).map((u) => '${u['first_name']} (${u['total_referrals']} referrals)').join(', ')}
• Active referral program with achievements and rewards
• Growing community of CloudWalk users
''';
  }

  /// Check if OpenAI is properly configured
  static Future<bool> isConfigured() async {
    try {
      await dotenv.load(fileName: ".env");
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      return apiKey != null && apiKey.isNotEmpty && apiKey != 'your-openai-api-key-here';
    } catch (e) {
      return false;
    }
  }
  
  /// Test the OpenAI API connection
  static Future<String> testConnection() async {
    try {
      // Load API key from .env file
      await dotenv.load(fileName: '.env');
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OPENAI_API_KEY not found in .env file');
      }
      
      initialize(apiKey);
      
      final testCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text("Just respond 'Connection OK' if you're working."),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
        maxTokens: 10,
      );
      
      final response = testCompletion.choices.first.message.content?.first.text ?? '';
      return 'Test successful: $response';
      
    } catch (e) {
      return 'Test failed: ${e.toString()}';
    }
  }
}
