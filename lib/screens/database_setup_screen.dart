import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/database_auth_service.dart';
import '../services/database_referral_service.dart';

class DatabaseSetupScreen extends StatefulWidget {
  const DatabaseSetupScreen({super.key});

  @override
  State<DatabaseSetupScreen> createState() => _DatabaseSetupScreenState();
}

class _DatabaseSetupScreenState extends State<DatabaseSetupScreen> {
  bool _isLoading = false;
  bool _isConnected = false;
  String _statusMessage = '';
  Map<String, dynamic> _dbStats = {};

  @override
  void initState() {
    super.initState();
    _checkDatabaseStatus();
  }

  Future<void> _checkDatabaseStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Verificando conexão com PostgreSQL...';
    });

    try {
      await DatabaseService.initialize();
      final stats = await DatabaseService.getDatabaseStats();
      
      setState(() {
        _isConnected = DatabaseService.isAvailable;
        _dbStats = stats;
        _statusMessage = _isConnected 
          ? 'Conectado ao PostgreSQL com sucesso!' 
          : 'PostgreSQL não disponível - usando modo local';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Erro de conexão: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _populateSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Criando dados de exemplo...';
    });

    try {
      await DatabaseAuthService.populateSampleData();
      
      // Generate referral links for sample users
      final users = await DatabaseAuthService.getAllUsers();
      for (final user in users) {
        await DatabaseReferralService.generateReferralLink(user);
      }
      
      // Simulate activity
      await DatabaseReferralService.simulateSampleActivity();
      
      // Refresh stats
      final stats = await DatabaseService.getDatabaseStats();
      
      setState(() {
        _dbStats = stats;
        _statusMessage = 'Dados de exemplo criados com sucesso!';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados de exemplo criados! 🎉'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao criar dados: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Limpeza'),
        content: const Text('Tem certeza que deseja limpar todos os dados do banco? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Limpando banco de dados...';
    });

    try {
      if (DatabaseService.isAvailable) {
        final connection = DatabaseService.connection!;
        await connection.execute('DELETE FROM referral_clicks');
        await connection.execute('DELETE FROM referral_links');
        await connection.execute('DELETE FROM user_achievements');
        await connection.execute('DELETE FROM users');
        
        final stats = await DatabaseService.getDatabaseStats();
        
        setState(() {
          _dbStats = stats;
          _statusMessage = 'Banco de dados limpo com sucesso!';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Banco de dados limpo! 🧹'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao limpar banco: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PostgreSQL Setup'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status da Conexão',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Database Statistics
            if (_isConnected && _dbStats.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estatísticas do Banco',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Total de Usuários', _dbStats['totalUsers'].toString()),
                      _buildStatRow('Links de Indicação', _dbStats['totalLinks'].toString()),
                      _buildStatRow('Total de Cliques', _dbStats['totalClicks'].toString()),
                      _buildStatRow('Registros Completos', _dbStats['totalCompletions'].toString()),
                      _buildStatRow('Taxa de Conversão', '${((_dbStats['conversionRate'] as double) * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],

            // Database Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ações do Banco de Dados',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Reconnect Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _checkDatabaseStatus,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Verificar Conexão'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F2937),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Populate Sample Data
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading || !_isConnected ? null : _populateSampleData,
                        icon: const Icon(Icons.people),
                        label: const Text('Criar Dados de Exemplo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Clear Database
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading || !_isConnected ? null : _clearDatabase,
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Limpar Banco de Dados'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // PostgreSQL Setup Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como Configurar PostgreSQL',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    const Text('1. Instale PostgreSQL:'),
                    const Text('   • Ubuntu: sudo apt install postgresql'),
                    const Text('   • macOS: brew install postgresql'),
                    const Text('   • Windows: Baixe do postgresql.org'),
                    const SizedBox(height: 8),
                    const Text('2. Crie o banco de dados:'),
                    const Text('   sudo -u postgres createdb cloudwalk_referrals'),
                    const SizedBox(height: 8),
                    const Text('3. Configure o arquivo .env:'),
                    const Text('   DB_HOST=localhost'),
                    const Text('   DB_PORT=5432'),
                    const Text('   DB_NAME=cloudwalk_referrals'),
                    const Text('   DB_USER=postgres'),
                    const Text('   DB_PASSWORD=sua_senha'),
                    const SizedBox(height: 8),
                    const Text('4. Reinicie a aplicação'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

