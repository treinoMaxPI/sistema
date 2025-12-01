import 'package:flutter/material.dart';
import 'package:gym_management/theme/typography.dart';
import 'package:gym_management/widgets/page_header.dart';
import 'package:gym_management/services/relatorio_service.dart';
import 'package:gym_management/widgets/charts/bar_chart.dart';
import 'package:gym_management/widgets/charts/pie_chart.dart';

class AdminRelatoriosPage extends StatefulWidget {
  const AdminRelatoriosPage({super.key});

  @override
  State<AdminRelatoriosPage> createState() => _AdminRelatoriosPageState();
}

class _AdminRelatoriosPageState extends State<AdminRelatoriosPage> {
  final RelatorioService _service = RelatorioService();
  bool _loading = true;
  String? _error;
  List<EntradaSaidaReportItem> _entradasSaidas = [];
  PagamentoResumo? _resumo;
  DateTimeRange? _range;
  bool _devDialogShown = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_devDialogShown) {
        _devDialogShown = true;
        _showDevelopmentDialog();
      }
    });
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final inicio = _range?.start;
    final fim = _range?.end;
    final r1 = await _service.listarEntradasSaidas(inicio: inicio, fim: fim);
    final r2 = await _service.obterResumoPagamentos(inicio: inicio, fim: fim);
    setState(() {
      _entradasSaidas = r1.success ? (r1.data ?? []) : [];
      _resumo = r2.success ? r2.data : PagamentoResumo(pagos: 0, pendentes: 0, quitados: 0);
      _loading = false;
      _error = null; // não bloquear a tela por erro; mostrar conteúdo com mensagens de vazio
    });
  }

  Future<void> _selecionarPeriodo() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range ?? DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
    );
    if (picked != null) {
      setState(() {
        _range = picked;
      });
      await _carregar();
    }
  }

  List<BarData> _buildBarsFromEntradas() {
    final map = <String, int>{};
    for (final e in _entradasSaidas) {
      final key = '${e.data.year}-${e.data.month.toString().padLeft(2, '0')}-${e.data.day.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + 1;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => BarData(e.key.substring(5), e.value.toDouble())).toList();
  }

  List<PieSlice> _buildPaymentPie() {
    final pagos = _resumo?.pagos ?? 0;
    final pendentes = _resumo?.pendentes ?? 0;
    final quitados = _resumo?.quitados ?? 0;
    return [
      PieSlice('Pagos', pagos.toDouble(), const Color(0xFF4CAF50)),
      PieSlice('Pendentes', pendentes.toDouble(), const Color(0xFFFF9800)),
      PieSlice('Quitados', quitados.toDouble(), const Color(0xFF2196F3)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PageHeader(title: 'Relatórios'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              color: const Color(0xFFFF312E),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _selecionarPeriodo,
                            icon: const Icon(Icons.date_range),
                            label: Text(_range == null ? 'Selecionar período' : '${_range!.start.day}/${_range!.start.month}/${_range!.start.year} - ${_range!.end.day}/${_range!.end.month}/${_range!.end.year}'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF312E), foregroundColor: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _loading ? null : _carregar,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Atualizar dados'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF312E), foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Entradas e saídas', style: AppTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Builder(builder: (context) {
                              final bars = _buildBarsFromEntradas();
                              if (bars.isEmpty) {
                                return Text('Ainda não tem entradas e saídas.', style: AppTypography.caption);
                              }
                              return SimpleBarChart(data: bars);
                            }),
                            const SizedBox(height: 16),
                            ..._entradasSaidas.take(10).map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(e.nome, style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface))),
                                      SizedBox(width: 120, child: Text('${e.data.day}/${e.data.month}/${e.data.year}', style: AppTypography.caption)),
                                      SizedBox(width: 80, child: Text(e.entrada ?? '-', style: AppTypography.caption)),
                                      SizedBox(width: 80, child: Text(e.saida ?? '-', style: AppTypography.caption)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pagamentos', style: AppTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: Builder(builder: (context) {
                                  final slices = _buildPaymentPie();
                                  final total = (_resumo?.pagos ?? 0) + (_resumo?.pendentes ?? 0) + (_resumo?.quitados ?? 0);
                                  if (total == 0) {
                                    return Text('Sem dados de pagamento para o período selecionado.', style: AppTypography.caption);
                                  }
                                  return SimplePieChart(slices: slices);
                                })),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pagos: ${_resumo?.pagos ?? 0}', style: AppTypography.bodyMedium),
                                      Text('Pendentes: ${_resumo?.pendentes ?? 0}', style: AppTypography.bodyMedium),
                                      Text('Quitados: ${_resumo?.quitados ?? 0}', style: AppTypography.bodyMedium),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _showDevelopmentDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).colorScheme.outline)),
          title: Text('Atenção', style: AppTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
          content: Text('Esta tela está em desenvolvimento. Algumas funcionalidades podem não estar disponíveis.', style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).maybePop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF312E), foregroundColor: Colors.white),
              child: const Text('Voltar'),
            ),
          ],
        );
      },
    );
  }
}
