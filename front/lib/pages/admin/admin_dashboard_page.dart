import 'package:flutter/material.dart';
import '../../theme/typography.dart';
import '../../services/dashboard_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final DashboardService _dashboardService = DashboardService();
  AdminDashboardResponse? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  Future<void> _carregarDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final response = await _dashboardService.getAdminDashboard();
    if (response.success && response.data != null) {
      setState(() {
        _dashboardData = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Erro ao carregar dashboard';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Admin Dashboard',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF312E),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _carregarDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF312E),
                        ),
                        child: const Text(
                          'Tentar Novamente',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : _dashboardData != null
                  ? RefreshIndicator(
                      onRefresh: _carregarDashboard,
                      color: const Color(0xFFFF312E),
                      child: _buildDashboardContent(),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum dado disponível',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Não há dados para exibir no dashboard.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDashboardContent() {
    final data = _dashboardData!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Visão Geral',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // Metrics Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: [
                  _buildMetricCard(
                    title: 'Receita do Mês',
                    value:
                        'R\$${data.totalRevenueMonthInReais.toStringAsFixed(2)}',
                    subtitle:
                        'Crescimento: ${data.percentualRevenueGrowthMonth.toStringAsFixed(1)}%',
                    icon: Icons.attach_money,
                    color: const Color(0xFF4CAF50),
                    trend: data.percentualRevenueGrowthMonth >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                  ),
                  _buildMetricCard(
                    title: 'Total de Membros',
                    value: data.totalNumberMembers.toString(),
                    subtitle:
                        'Ativos: ${data.totalNumberPaidMembers} | Inativos: ${data.totalNumberUnpaidMembers}',
                    icon: Icons.people,
                    color: const Color(0xFF2196F3),
                    trend: Icons.people_alt,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats Section
              _buildStatsSection(data),

              const SizedBox(height: 24),

              // Distribution Card
              _buildDistributionCard(data.userDistributionByPlan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required IconData trend,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(trend, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(AdminDashboardResponse data) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF312E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.insights, color: const Color(0xFFFF312E), size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Estatísticas Detalhadas',
                  style: AppTypography.titleSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatRow(
              'Membros Ativos',
              data.totalNumberPaidMembers.toString(),
              Icons.check_circle,
              const Color(0xFF4CAF50),
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Membros Inativos',
              data.totalNumberUnpaidMembers.toString(),
              Icons.pause_circle,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildStatRow(
              'Taxa de Retenção',
              data.totalNumberMembers > 0
                  ? '${((data.totalNumberPaidMembers / data.totalNumberMembers) * 100).toStringAsFixed(1)}%'
                  : '0%',
              Icons.trending_up,
              const Color(0xFFFF312E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionCard(Map<String, double> distribution) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF312E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.pie_chart, color: const Color(0xFFFF312E), size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Distribuição por Plano',
                  style: AppTypography.titleSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (distribution.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhum plano ativo',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...distribution.entries.toList().asMap().entries.map((mapEntry) {
                final index = mapEntry.key;
                final entry = mapEntry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < distribution.length - 1 ? 16 : 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF312E).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${entry.value.toStringAsFixed(1)}%',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: const Color(0xFFFF312E),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: entry.value / 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFF312E),
                                        const Color(0xFFFF312E).withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
