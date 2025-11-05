import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userName;
  String? _jwtToken;
  JwtPayload? _parsedJwt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final userName = await authService.getUserName();
    final token = await authService.getAccessToken();
    final parsedJwt = await authService.getParsedAccessToken();

    setState(() {
      _userName = userName;
      _jwtToken = token;
      _parsedJwt = parsedJwt;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final authService = AuthService();
    await authService.logout();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Academias'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo, ${_userName ?? 'Usuário'}!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sistema de Gestão de Academias',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // JWT Token Section
                  if (_jwtToken != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.security, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'JWT Token Information',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Raw JWT Token
                            _buildInfoRow('JWT Token:', _jwtToken!),
                            const SizedBox(height: 8),

                            // Parsed JWT Content
                            if (_parsedJwt != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Parsed JWT Content:',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: SelectableText(
                                  _formatJson(_parsedJwt!),
                                  style: const TextStyle(
                                    fontFamily: 'Monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Features grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.people,
                          title: 'Alunos',
                          subtitle: 'Gerenciar alunos',
                          color: Colors.blue,
                        ),
                        _buildFeatureCard(
                          icon: Icons.fitness_center,
                          title: 'Treinos',
                          subtitle: 'Criar treinos',
                          color: Colors.green,
                        ),
                        _buildFeatureCard(
                          icon: Icons.calendar_today,
                          title: 'Agenda',
                          subtitle: 'Agendamentos',
                          color: Colors.orange,
                        ),
                        _buildFeatureCard(
                          icon: Icons.payment,
                          title: 'Financeiro',
                          subtitle: 'Pagamentos',
                          color: Colors.purple,
                        ),
                        _buildFeatureCard(
                          icon: Icons.bar_chart,
                          title: 'Relatórios',
                          subtitle: 'Relatórios',
                          color: Colors.red,
                        ),
                        _buildFeatureCard(
                          icon: Icons.settings,
                          title: 'Configurações',
                          subtitle: 'Configurações',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            value,
            style: const TextStyle(
              fontFamily: 'Monospace',
              fontSize: 12,
            ),
            maxLines: 2,
            // overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatJson(JwtPayload jwt) {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jwt.toJson());
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Placeholder for feature navigation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title - Funcionalidade em desenvolvimento'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
