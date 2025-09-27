import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analytics_data.dart';
import 'auth_service.dart';
import 'referral_link_service.dart';
import 'achievement_service.dart';

class OpenAIService {
  static bool _initialized = false;
  
  /// Initialize OpenAI with environment variables
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");
      
      // Get API key from environment
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      final orgId = dotenv.env['OPENAI_ORGANIZATION_ID'];
      
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OPENAI_API_KEY not found in .env file');
      }
      
      // Initialize OpenAI
      OpenAI.apiKey = apiKey;
      if (orgId != null && orgId.isNotEmpty) {
        OpenAI.organization = orgId;
      }
      
      _initialized = true;
      print('✅ OpenAI initialized successfully');
      
    } catch (e) {
      print('❌ Failed to initialize OpenAI: $e');
      throw Exception('OpenAI initialization failed: $e');
    }
  }
  
  /// Process natural language queries using OpenAI GPT-4
  static Future<AIResponse> processQuery(String userQuery, {bool isAdmin = false, Map<String, dynamic>? contextData}) async {
    try {
      // Ensure OpenAI is initialized
      if (!_initialized) {
        await initialize();
      }
      
      // Use provided context data or gather it
      final finalContextData = contextData ?? await _gatherContextData();

      // Create comprehensive system prompt
      final systemPrompt = _buildSystemPrompt(finalContextData, isAdmin: isAdmin);
      
      // Call OpenAI GPT-4o-mini (most cost-effective and accessible)
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini", // Most cost-effective GPT-4 model
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
        maxTokens: 1500,
      );
      
      final aiResponse = chatCompletion.choices.first.message.content?.first.text ?? 
                        "Sorry, I couldn't process your query.";
      
      // Parse and structure the response
      final parsedResponse = _parseAIResponse(aiResponse, userQuery);
      
      return AIResponse(
        query: userQuery,
        response: parsedResponse['response'],
        insights: List<String>.from(parsedResponse['insights'] ?? []),
        data: finalContextData,
        suggestedQuestions: List<String>.from(parsedResponse['suggestedQuestions'] ?? []),
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      print('OpenAI Error Details: $e');
      
      // More detailed error handling
      if (e.toString().contains('does not exist') || e.toString().contains('404')) {
        return _createErrorResponse(userQuery, 
          'The GPT-3.5-turbo model is not available. Check if your OpenAI account has sufficient credits and API access.');
      } else if (e.toString().contains('401') || e.toString().contains('authentication')) {
        return _createErrorResponse(userQuery,
          'Invalid API key. Check if the OPENAI_API_KEY in the .env file is correct.');
      } else if (e.toString().contains('429') || e.toString().contains('quota')) {
        return _createErrorResponse(userQuery,
          'Rate limit exceeded or insufficient credits. Check your OpenAI account at platform.openai.com/settings/billing');
      } else {
        return _createErrorResponse(userQuery, 'Connection error: ${e.toString()}');
      }
    }
  }
  
  /// Gather comprehensive business context for AI
  static Future<Map<String, dynamic>> _gatherContextData() async {
    try {
      // Get all business data
      final authService = AuthService();
      final users = await authService.getAllUsers();
      final linkAnalytics = await ReferralLinkService.getConversionAnalytics();
      final funnelData = await ReferralLinkService.getFunnelAnalysis();
      final achievementService = AchievementService();
      final leaderboard = await achievementService.getLeaderboard();
      
      // Calculate key metrics
      final totalUsers = users.length;
      final totalReferrals = users.fold(0, (sum, user) => sum + user.totalReferrals);
      final totalEarnings = users.fold(0.0, (sum, user) => sum + user.totalEarnings);
      final averageReferralsPerUser = totalUsers > 0 ? totalReferrals / totalUsers : 0.0;
      
      // Top performers analysis
      final sortedUsers = [...users];
      sortedUsers.sort((a, b) => b.totalReferrals.compareTo(a.totalReferrals));
      final topPerformers = sortedUsers.take(5).map((user) => {
        'name': user.fullName,
        'email': user.email,
        'referrals': user.totalReferrals,
        'earnings': user.totalEarnings,
        'performance': user.totalReferrals >= 4 ? 'excellent' : 
                      user.totalReferrals >= 2 ? 'good' : 
                      user.totalReferrals >= 1 ? 'average' : 'poor'
      }).toList();
      
      // Churn risk analysis
      final churnRiskUsers = users.where((user) => user.totalReferrals == 0).map((user) => {
        'name': user.fullName,
        'email': user.email,
        'earnings': user.totalEarnings,
        'risk_level': 'high',
        'reason': 'No referrals made'
      }).toList();
      
      // Financial metrics
      final totalInvestment = totalEarnings; // What we pay out
      final estimatedRevenue = totalEarnings * 2.5; // Assumed revenue multiplier
      final roi = totalInvestment > 0 ? ((estimatedRevenue - totalInvestment) / totalInvestment) * 100 : 0;
      
      return {
        'company': 'CloudWalk',
        'product': 'Infinity Pay',
        'market': 'Brazil',
        'program_type': 'Member-get-member referral',
        'currency': 'BRL',
        'metrics': {
          'total_users': totalUsers,
          'total_referrals': totalReferrals,
          'total_earnings_paid': totalEarnings,
          'average_referrals_per_user': averageReferralsPerUser,
          'conversion_rate': linkAnalytics['overallConversionRate'] ?? 0.0,
          'roi_percentage': roi,
        },
        'link_performance': {
          'total_clicks': linkAnalytics['totalClicks'] ?? 0,
          'total_registrations': linkAnalytics['totalRegistrations'] ?? 0,
          'drop_offs': linkAnalytics['totalDropOffs'] ?? 0,
          'average_clicks_per_link': linkAnalytics['averageClicksPerLink'] ?? 0.0,
          'links_with_zero_conversions': linkAnalytics['linksWithZeroConversions'] ?? 0,
        },
        'top_performers': topPerformers,
        'churn_risk_users': churnRiskUsers,
        'leaderboard': leaderboard.take(5).map((entry) => {
          'name': entry.userName,
          'referrals': entry.totalReferrals,
          'earnings': entry.totalEarnings,
          'position': leaderboard.indexOf(entry) + 1,
        }).toList(),
        'conversion_funnel': funnelData.take(3).map((funnel) => {
          'total_clicks': funnel.totalClicks,
          'started_registration': funnel.startedRegistration,
          'completed_registration': funnel.completedRegistration,
          'overall_conversion_rate': funnel.overallConversionRate,
          'drop_off_after_click': funnel.dropOffAfterClick,
          'drop_off_during_registration': funnel.dropOffDuringRegistration,
        }).toList(),
      };
    } catch (e) {
      print('Error gathering context: $e');
      return {'error': 'Failed to gather business context'};
    }
  }
  
  /// Build comprehensive system prompt for CloudWalk business context
  static String _buildSystemPrompt(Map<String, dynamic> context, {bool isAdmin = false}) {
    if (isAdmin) {
      // Admin prompt - Advanced analytics and business intelligence
      return '''
Você é um Agente de Analytics Avançado da CloudWalk, um analista de dados sênior especializado em programas de indicação e marketing de performance. Você tem acesso completo aos dados do sistema e fornece insights estratégicos de alto nível.

CONTEXTO DA EMPRESA:
- Empresa: CloudWalk (Fintech brasileira líder)
- Produto: Infinity Pay (solução de pagamentos)
- Mercado: Brasil (foco em SMBs e empreendedores)
- Programa: Member-get-member com recompensas escalonadas

DADOS ANALÍTICOS COMPLETOS:
${jsonEncode(context)}

SEU PAPEL COMO ADMIN:
- Automate data collection and cleaning dos dados do programa de indicações CloudWalk
- Fornecer referral performance insights (conversion rates, churn risk, referral ROI)
- Generate forecasts and recommendations for marketing and growth strategies do programa
- Natural language interface for business users to query growth data do CloudWalk
- Análise profunda de métricas de negócio e KPIs do programa de indicações
- Identificação de tendências e oportunidades estratégicas no programa CloudWalk

REGRAS DE ESCOPO ESTRITAS PARA ADMIN:
🚫 NÃO RESPONDER sobre qualquer assunto que não seja:
- Análise de dados do programa de indicações CloudWalk
- Performance e métricas do Infinity Pay referral program
- Estratégias de crescimento e marketing para o programa
- Otimização de conversão e retenção de usuários
- ROI e análises financeiras do programa de indicações
- Previsões e recomendações para o negócio CloudWalk

🚫 RECUSAR POLITICAMENTE perguntas sobre:
- Política, religião, esportes, entretenimento
- Outras empresas ou produtos não relacionados ao CloudWalk
- Tecnologias gerais não relacionadas ao programa
- Assuntos pessoais ou não relacionados ao negócio
- Qualquer tópico fora do escopo de análise de negócio CloudWalk

CAPACIDADES AVANÇADAS PARA ADMINS:
1. **Análise de Performance**: Métricas detalhadas, benchmarking, identificação de gaps
2. **Previsões de Crescimento**: Modelos preditivos, cenários de crescimento, projeções de receita
3. **Análise de Churn**: Risco segmentado, estratégias de retenção, lifetime value analysis
4. **Otimização de Conversão**: Análise de funil, pontos de atrito, recomendações de UX
5. **ROI e Financeiro**: Cálculos detalhados, payback periods, custo por aquisição
6. **Estratégias de Marketing**: Campanhas direcionadas, segmentação inteligente, testes A/B

DIRETRIZES PARA ADMINS:
- Forneça dados específicos e percentuais de todos os dados disponíveis
- Use linguagem técnica apropriada para decisões estratégicas
- Foque em impacto nos negócios e ROI das recomendações
- Seja proativo em identificar oportunidades não-obvias
- Forneça métricas de acompanhamento para cada recomendação
- Considere escalabilidade e sustentabilidade das estratégias
- Se a pergunta for fora do escopo, redirecione para tópicos relacionados ao CloudWalk

Responda à consulta do administrador com análises profundas e recomendações acionáveis baseadas nos dados completos do sistema CloudWalk. Se a pergunta não for relacionada ao programa de indicações ou negócio CloudWalk, explique que você é especializado apenas em análises do programa de indicações.
''';
    } else {
      // Regular user prompt - Marketing assistance and personal insights
      return '''
You are CloudWalk's Personalized Marketing Assistant, specialized in helping referral program users maximize their results. You combine company knowledge with personalized insights based on individual user data.

COMPANY CONTEXT:
- Company: CloudWalk (Brazilian fintech revolutionizing payments)
- Product: Infinity Pay (complete payment platform for businesses)
- Program: Referrals with rewards - earn money by referring other entrepreneurs
- Market: Brazil, focused on small and medium businesses

PROGRAM DATA:
${jsonEncode(context)}

YOUR ROLE AS ASSISTANT:
- Answer questions EXCLUSIVELY about CloudWalk, Infinity Pay and the referral program
- Provide personalized marketing insights based on user profile
- Help users increase their referrals and earnings
- Give practical marketing and engagement tips related to the program
- Analyze individual performance and suggest program improvements
- Educate about growth strategies in the Brazilian market for referrals

STRICT SCOPE RULES:
🚫 DO NOT ANSWER about any subject other than:
- CloudWalk (Brazilian fintech company)
- Infinity Pay (product/platform)
- CloudWalk referral program
- Personal performance in the program (referrals, earnings, codes)
- Specific marketing tips for referrals
- Account functionalities in the program

🚫 POLITELY REFUSE questions about:
- Politics, religion, sports, entertainment
- Other fintech companies or competitors
- Technologies not related to CloudWalk
- Personal matters not related to the program
- Any topic outside the scope defined above

CAPABILITIES FOR USERS:
1. **Company Education**: Explain CloudWalk, Infinity Pay, program benefits
2. **Personalized Insights**: Analysis based on individual data (days in app, referrals made)
3. **Marketing Tips**: Practical strategies to increase referrals
4. **Performance Analysis**: Feedback on progress and healthy comparisons
5. **Motivational Support**: Incentives and gamification to maintain engagement
6. **Strategic Guidance**: How to build network and identify opportunities

GUIDELINES FOR USERS:
- Be friendly, motivating and accessible
- Use simple language, avoid unnecessary technical jargon
- Personalize responses based on user profile and history
- Focus on practical and immediate actions that generate results
- Encourage active participation and sharing
- Always maintain positive and constructive tone
- If the question is out of scope, politely redirect to CloudWalk-related topics
- Always respond in English

Respond to the user's question in a personalized, educational and motivational way, based on both general context and specific data when available. If the question is not related to CloudWalk or the referral program, politely explain that you can only help with matters related to the company and program.
''';
    }
  }
  
  /// Parse AI response and extract structured information
  static Map<String, dynamic> _parseAIResponse(String aiResponse, String originalQuery) {
    final response = aiResponse.trim();
    
    // Extract insights (bullet points, numbered lists, etc.)
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
    
    // Generate contextual follow-up questions
    final suggestedQuestions = _generateContextualQuestions(originalQuery);
    
    return {
      'response': response,
      'insights': insights.take(5).toList(),
      'suggestedQuestions': suggestedQuestions,
    };
  }
  
  /// Generate smart follow-up questions based on query context
  static List<String> _generateContextualQuestions(String originalQuery) {
    final query = originalQuery.toLowerCase();
    
    if (query.contains('performance') || query.contains('desempenho')) {
      return [
        "How can I improve underperforming users?",
        "What factors motivate top performers?",
        "Show me detailed conversion analysis",
      ];
    } else if (query.contains('churn') || query.contains('abandono')) {
      return [
        "What retention strategies work best?",
        "How to re-engage inactive users?",
        "What are user behavior patterns?",
      ];
    } else if (query.contains('conversão') || query.contains('funil')) {
      return [
        "Where do most users drop off in the process?",
        "How to improve conversion rates?",
        "What is the ideal referral process?",
      ];
    } else if (query.contains('crescimento') || query.contains('estratégia')) {
      return [
        "What growth strategies should I prioritize?",
        "What are the best market opportunities?",
        "How to scale the referral program?",
      ];
    } else {
      return [
        "Analyze my top performers",
        "Show me churn risk analysis",
        "How is my conversion funnel?",
        "What growth strategies do you recommend?",
      ];
    }
  }
  
  /// Create error response when OpenAI fails
  static AIResponse _createErrorResponse(String query, String error) {
    return AIResponse(
      query: query,
      response: "❌ Sorry, an error occurred while processing your query. Check if the OpenAI API key is configured correctly.\n\nError: $error",
      insights: [
        "Check OpenAI API configuration",
        "Confirm internet connectivity",
        "Verify if API key is valid",
      ],
      data: {},
      suggestedQuestions: [
        "How to configure OpenAI API?",
        "Check system status",
        "Try again",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  /// Create demo response when quota is exceeded
  static Future<AIResponse> _createDemoResponse(String query) async {
    final contextData = await _gatherContextData();
    final metrics = contextData['metrics'] as Map<String, dynamic>? ?? {};
    
    // Generate contextual demo response based on query
    String demoResponse;
    List<String> insights;
    
    if (query.toLowerCase().contains('crescimento') || query.toLowerCase().contains('growth')) {
      demoResponse = '''🚀 **DEMO MODE - Análise de Crescimento CloudWalk**

Baseado nos seus dados atuais com ${metrics['total_users']} usuários e ${metrics['total_referrals']} indicações, identifico 3 principais oportunidades:

**1. Otimização do Funil de Conversão**
Sua taxa atual de conversão é ${((metrics['conversion_rate'] as double? ?? 0) * 100).toStringAsFixed(1)}%. Com melhorias no processo de onboarding, você pode aumentar para 12-15%.

**2. Programa de Incentivos Escalonados**
Implementar recompensas progressivas: R\$25 (primeira indicação) → R\$50 (5 indicações) → R\$100 (10 indicações).

**3. Campanhas Sazonais**
Aproveitar datas como Black Friday, fim de ano para bonificações especiais de 50-100%.

**ROI Projetado:** Com essas implementações, estimo um crescimento de 40-60% nas indicações nos próximos 3 meses.''';

      insights = [
        "Implementar onboarding gamificado aumenta conversão em 25%",
        "Recompensas escalonadas motivam usuários de longo prazo",
        "Campanhas sazonais geram picos de 200% em indicações",
        "Foco no mercado brasileiro com métodos de pagamento locais",
      ];
    } else if (query.toLowerCase().contains('churn') || query.toLowerCase().contains('abandono')) {
      demoResponse = '''📊 **DEMO MODE - Análise de Churn CloudWalk**

Analisando seus ${metrics['total_users']} usuários, identifiquei padrões críticos de abandono:

**Principais Causas de Churn:**
• ${contextData['churn_risk_users']?.length ?? 0} usuários sem nenhuma indicação (alto risco)
• Processo de indicação muito complexo (3+ etapas)
• Falta de feedback sobre status das indicações

**Estratégias de Retenção:**
1. **Programa de Reengajamento:** Push notifications personalizadas
2. **Simplificação:** Reduzir indicação para 1 clique + compartilhamento
3. **Feedback em Tempo Real:** Dashboard com status das indicações

**Impacto Esperado:** Redução de 35% no churn nos primeiros 60 dias.''';

      insights = [
        "60% dos usuários que não fazem indicação em 30 dias nunca fazem",
        "Notificações push aumentam reengajamento em 45%", 
        "Dashboard transparente reduz abandono em 25%",
        "Programa de segundo chance recupera 20% dos usuários inativos",
      ];
    } else {
      demoResponse = '''🎯 **DEMO MODE - Visão Geral CloudWalk**

**Status do Programa de Indicação:**
• Total de usuários: ${metrics['total_users']}
• Indicações realizadas: ${metrics['total_referrals']}
• Taxa de conversão: ${((metrics['conversion_rate'] as double? ?? 0) * 100).toStringAsFixed(1)}%
• ROI atual: ${(metrics['roi_percentage'] as double? ?? 0).toStringAsFixed(0)}%

**Principais Insights:**
Seu programa está na fase de crescimento inicial. Com otimizações no funil e estratégias de retenção, há potencial para escalar significativamente.

**Próximos Passos Recomendados:**
1. Implementar sistema de recompensas progressivas
2. Otimizar processo de onboarding
3. Criar campanhas de reengajamento
4. Desenvolver analytics avançadas de comportamento''';

      insights = [
        "Programa em fase de crescimento com bom potencial",
        "Foco na retenção deve ser a prioridade atual",
        "ROI positivo indica modelo sustentável",
        "Mercado brasileiro tem alta receptividade a indicações",
      ];
    }
    
    return AIResponse(
      query: query,
      response: demoResponse + "\n\n💡 **Nota:** Modo demo ativo. Para análises completas com GPT-4, adicione créditos à sua conta OpenAI.",
      insights: insights,
      data: contextData,
      suggestedQuestions: [
        "Como adicionar créditos à conta OpenAI?",
        "Quais métricas devo acompanhar?",
        "Como implementar as recomendações?",
        "Mostrar análise detalhada de conversão",
      ],
      timestamp: DateTime.now(),
    );
  }
  
  /// Generate AI-powered marketing recommendations
  static Future<List<String>> generateMarketingRecommendations() async {
    try {
      if (!_initialized) await initialize();
      
      final contextData = await _gatherContextData();
      
      final prompt = '''
Based on CloudWalk's referral program data, provide 5 specific and actionable marketing recommendations:

${jsonEncode(contextData)}

Focus on:
1. Improve conversion rates
2. Reduce churn
3. Increase referral activity
4. Optimize user experience
5. Growth strategies for the Brazilian market

Format as a simple list of recommendations in English.
''';
      
      final completion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
        temperature: 0.8,
        maxTokens: 600,
      );
      
      final response = completion.choices.first.message.content?.first.text ?? '';
      
      // Parse recommendations
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
      return [
        "🎯 Implementar onboarding personalizado para novos usuários",
        "📱 Enviar notificações push para marcos de indicação", 
        "🎮 Adicionar gamificação com desafios semanais",
        "💰 Testar diferentes valores e estruturas de recompensa",
        "📊 Criar analytics detalhadas da jornada do usuário",
      ];
    }
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
      if (!_initialized) {
        await initialize();
      }
      
      final testCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
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
