import 'package:flutter/material.dart';
import '../models/referral_link.dart';
import '../services/referral_link_service.dart';

class ChurnAnalyticsScreen extends StatefulWidget {
  const ChurnAnalyticsScreen({super.key});

  @override
  State<ChurnAnalyticsScreen> createState() => _ChurnAnalyticsScreenState();
}

class _ChurnAnalyticsScreenState extends State<ChurnAnalyticsScreen> {
  Map<String, dynamic>? _analytics;
  List<ConversionFunnel>? _funnelData;
  List<ReferralLink>? _links;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final analytics = await ReferralLinkService.getConversionAnalytics();
      final funnelData = await ReferralLinkService.getFunnelAnalysis();
      final links = await ReferralLinkService.getAllReferralLinks();

      setState(() {
        _analytics = analytics;
        _funnelData = funnelData;
        _links = links;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Abandono'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(),
                  const SizedBox(height: 16),
                  _buildFunnelAnalysis(),
                  const SizedBox(height: 16),
                  _buildLinkPerformance(),
                  const SizedBox(height: 16),
                  _buildActionableInsights(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    final analytics = _analytics!;
    final totalClicks = analytics['totalClicks'] as int;
    final totalRegistrations = analytics['totalRegistrations'] as int;
    final dropOffs = analytics['totalDropOffs'] as int;
    final conversionRate = analytics['overallConversionRate'] as double;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Color(0xFF1F2937)),
                const SizedBox(width: 8),
                Text(
                  'Visão Geral do Funil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Total de Cliques',
                    totalClicks.toString(),
                    Icons.touch_app,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    'Registros Completos',
                    totalRegistrations.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Abandonos',
                    dropOffs.toString(),
                    Icons.warning,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    'Taxa de Conversão',
                    '${(conversionRate * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    conversionRate > 0.2 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelAnalysis() {
    if (_funnelData == null || _funnelData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Color(0xFF1F2937)),
                const SizedBox(width: 8),
                Text(
                  'Análise do Funil de Conversão',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_funnelData!.take(5).map((funnel) => _buildFunnelItem(funnel))),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnelItem(ConversionFunnel funnel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Link ${funnel.referralLinkId.substring(funnel.referralLinkId.length - 4)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: funnel.totalClicks,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text('${funnel.totalClicks} cliques'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: funnel.startedRegistration,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (funnel.totalClicks > funnel.startedRegistration)
                Expanded(
                  flex: funnel.totalClicks - funnel.startedRegistration,
                  child: Container(height: 8),
                ),
              const SizedBox(width: 4),
              Text('${funnel.startedRegistration} iniciaram'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: funnel.completedRegistration,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (funnel.totalClicks > funnel.completedRegistration)
                Expanded(
                  flex: funnel.totalClicks - funnel.completedRegistration,
                  child: Container(height: 8),
                ),
              const SizedBox(width: 4),
              Text('${funnel.completedRegistration} completaram'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa: ${(funnel.overallConversionRate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: funnel.overallConversionRate > 0.2 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (funnel.dropOffAfterClick > 0)
                Text(
                  '${funnel.dropOffAfterClick} abandonos',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkPerformance() {
    if (_links == null || _links!.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedLinks = [..._links!];
    sortedLinks.sort((a, b) => b.abandonedUsers.compareTo(a.abandonedUsers));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: Color(0xFF1F2937)),
                const SizedBox(width: 8),
                Text(
                  'Links com Mais Abandono',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(sortedLinks.take(5).map((link) => _buildLinkItem(link))),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(ReferralLink link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.userName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Código: ${link.linkCode}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${link.clickCount} cliques',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${link.abandonedUsers} abandonos',
                style: const TextStyle(color: Colors.red),
              ),
              Text(
                '${(link.conversionRate * 100).toStringAsFixed(1)}% conversão',
                style: TextStyle(
                  color: link.conversionRate > 0.2 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionableInsights() {
    final analytics = _analytics!;
    final totalDropOffs = analytics['totalDropOffs'] as int;
    final conversionRate = analytics['overallConversionRate'] as double;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFF1F2937)),
                const SizedBox(width: 8),
                Text(
                  'Insights e Recomendações',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (totalDropOffs > 0) ...[
              _buildInsightItem(
                '⚠️ Alto índice de abandono',
                '$totalDropOffs pessoas clicaram nos links mas não completaram o registro.',
                conversionRate < 0.1 ? 'Crítico' : 'Atenção',
                conversionRate < 0.1 ? Colors.red : Colors.orange,
              ),
              const SizedBox(height: 8),
            ],
            if (conversionRate < 0.15) ...[
              _buildInsightItem(
                '📈 Melhore a conversão',
                'Taxa atual de ${(conversionRate * 100).toStringAsFixed(1)}% está abaixo do ideal (15-25%).',
                'Ação necessária',
                Colors.orange,
              ),
              const SizedBox(height: 8),
            ],
            _buildInsightItem(
              '🎯 Sugestões de melhoria',
              'Simplifique o processo de registro, adicione tutoriais e envie lembretes por email.',
              'Recomendação',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String description, String tag, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
