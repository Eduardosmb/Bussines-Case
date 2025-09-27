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
  static Future<AIResponse> processQuery(String userQuery) async {
    try {
      // Ensure OpenAI is initialized
      if (!_initialized) {
        await initialize();
      }
      
      // Gather business context
      final contextData = await _gatherContextData();
      
      // Create comprehensive system prompt
      final systemPrompt = _buildSystemPrompt(contextData);
      
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
                        "Desculpe, não consegui processar sua consulta.";
      
      // Parse and structure the response
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
      print('OpenAI Error Details: $e');
      
      // More detailed error handling
      if (e.toString().contains('does not exist') || e.toString().contains('404')) {
        return _createErrorResponse(userQuery, 
          'O modelo GPT-3.5-turbo não está disponível. Verifique se sua conta OpenAI tem créditos suficientes e acesso à API.');
      } else if (e.toString().contains('401') || e.toString().contains('authentication')) {
        return _createErrorResponse(userQuery,
          'Chave da API inválida. Verifique se a OPENAI_API_KEY no arquivo .env está correta.');
      } else if (e.toString().contains('429') || e.toString().contains('quota')) {
        return _createErrorResponse(userQuery,
          'Limite de taxa excedido ou créditos insuficientes. Verifique sua conta OpenAI em platform.openai.com/settings/billing');
      } else {
        return _createErrorResponse(userQuery, 'Erro de conexão: ${e.toString()}');
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
  static String _buildSystemPrompt(Map<String, dynamic> context) {
    return '''
Você é um Agente de Dados de IA especializado no programa de indicação da CloudWalk. Você é um analista de negócios expert com profundo conhecimento em marketing de indicação, otimização de conversão e estratégias de crescimento no mercado brasileiro.

CONTEXTO DA EMPRESA:
- Empresa: CloudWalk (Fintech brasileira)
- Produto: Infinity Pay
- Mercado: Brasil
- Programa: Member-get-member (indicação entre membros)

DADOS ATUAIS DO NEGÓCIO:
${jsonEncode(context)}

SEU PAPEL:
- Analisar o desempenho do programa de indicação usando os dados fornecidos
- Fornecer insights acionáveis e recomendações específicas
- Responder perguntas sobre comportamento do usuário, taxas de conversão, risco de churn
- Sugerir estratégias específicas para o mercado brasileiro
- Falar em português brasileiro de forma natural e profissional

CAPACIDADES ESPECÍFICAS:
1. Análise de performance (top performers, taxas de conversão, ROI)
2. Avaliação de risco de churn (usuários com risco de sair, estratégias de retenção)
3. Análise de funil de conversão (pontos de abandono, oportunidades de otimização)
4. Previsões de crescimento e recomendações
5. Estratégias de marketing específicas para o Brasil
6. Análises financeiras (ROI, custo por aquisição, LTV)

DIRETRIZES DE RESPOSTA:
- Sempre responda em português brasileiro
- Use dados específicos e percentuais dos dados fornecidos
- Foque em insights acionáveis, não apenas em relatar números
- Seja direto e prático nas recomendações
- Considere o contexto do mercado brasileiro e fintech
- Use emojis ocasionalmente para tornar a resposta mais amigável

Responda à pergunta do usuário baseando-se nos dados de contexto fornecidos.
''';
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
        "Como posso melhorar os usuários com baixo desempenho?",
        "Quais fatores motivam os top performers?",
        "Mostre-me a análise detalhada de conversão",
      ];
    } else if (query.contains('churn') || query.contains('abandono')) {
      return [
        "Que estratégias de retenção funcionam melhor?",
        "Como reengajar usuários inativos?",
        "Quais são os padrões de comportamento dos usuários?",
      ];
    } else if (query.contains('conversão') || query.contains('funil')) {
      return [
        "Onde a maioria dos usuários abandona o processo?",
        "Como melhorar as taxas de conversão?",
        "Qual é o processo de indicação ideal?",
      ];
    } else if (query.contains('crescimento') || query.contains('estratégia')) {
      return [
        "Que estratégias de crescimento devo priorizar?",
        "Quais são as melhores oportunidades de mercado?",
        "Como escalar o programa de indicação?",
      ];
    } else {
      return [
        "Analise meus top performers",
        "Mostre-me a análise de risco de churn",
        "Como está meu funil de conversão?",
        "Que estratégias de crescimento você recomenda?",
      ];
    }
  }
  
  /// Create error response when OpenAI fails
  static AIResponse _createErrorResponse(String query, String error) {
    return AIResponse(
      query: query,
      response: "❌ Desculpe, ocorreu um erro ao processar sua consulta. Verifique se a chave da API do OpenAI está configurada corretamente.\n\nErro: $error",
      insights: [
        "Verificar configuração da API do OpenAI",
        "Confirmar conectividade com a internet",
        "Verificar se a chave da API é válida",
      ],
      data: {},
      suggestedQuestions: [
        "Como configurar a API do OpenAI?",
        "Verificar status do sistema",
        "Tentar novamente",
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
Com base nos dados do programa de indicação da CloudWalk, forneça 5 recomendações específicas e acionáveis de marketing:

${jsonEncode(contextData)}

Foque em:
1. Melhorar taxas de conversão
2. Reduzir churn
3. Aumentar atividade de indicação
4. Otimizar experiência do usuário
5. Estratégias de crescimento para o mercado brasileiro

Formate como uma lista simples de recomendações em português brasileiro.
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
              OpenAIChatCompletionChoiceMessageContentItemModel.text("Responda apenas 'Conexão OK' se você está funcionando."),
            ],
            role: OpenAIChatMessageRole.user,
          ),
        ],
        maxTokens: 10,
      );
      
      final response = testCompletion.choices.first.message.content?.first.text ?? '';
      return 'Teste bem-sucedido: $response';
      
    } catch (e) {
      return 'Teste falhou: ${e.toString()}';
    }
  }
}
