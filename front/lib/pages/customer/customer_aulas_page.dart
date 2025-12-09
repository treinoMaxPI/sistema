import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'dart:math' as math;
import '../../theme/typography.dart';
import '../../services/aula_service.dart';

class CustomerAulasPage extends StatefulWidget {
  const CustomerAulasPage({super.key});

  @override
  State<CustomerAulasPage> createState() => _CustomerAulasPageState();
}

class _CustomerAulasPageState extends State<CustomerAulasPage> {
  final AulaService _aulaService = AulaService();
  List<AulaResponse> _aulas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarAulas();
  }

  Future<void> _carregarAulas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final resp = await _aulaService.listarMinhasAulas();
    if (resp.success && resp.data != null) {
      setState(() {
        _aulas = resp.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = resp.message ?? 'Erro ao carregar aulas';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Aulas Disponíveis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : (_errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.bodyMedium.copyWith(color: Colors.redAccent),
                    ),
                  )
                : _aulas.isEmpty
                    ? const _EmptyStateAulas()
                    : ListView.separated(
                        itemCount: _aulas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final a = _aulas[index];
                          return _AulaCard(
                            aula: a,
                            formatDate: _formatDate,
                          );
                        },
                      )),
      ),
    );
  }

  String _formatDate(String iso) {
    DateTime dt;
    try {
      dt = DateTime.parse(iso).toLocal();
    } catch (_) {
      return iso;
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _EmptyStateAulas extends StatelessWidget {
  const _EmptyStateAulas();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 48),
          const SizedBox(height: 8),
          Text('Sem aulas disponíveis', style: AppTypography.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _AulaCard extends StatelessWidget {
  final AulaResponse aula;
  final String Function(String) formatDate;

  const _AulaCard({required this.aula, required this.formatDate});

  Color _cardColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _borderColor(BuildContext context) => Theme.of(context).colorScheme.outline;
  Color get _accent => const Color(0xFFFF312E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasImage) _buildImage(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 8),
                Text(aula.descricao, style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)), maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                _buildInfoRow(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasImage => (aula.imagemUrl != null && aula.imagemUrl!.trim().isNotEmpty);

  Widget _buildImage(BuildContext context) {
    String url = aula.imagemUrl!;
    if (url.startsWith('/')) {
      final uri = Uri.parse(AulaService.baseUrl);
      url = '${uri.scheme}://${uri.host}:${uri.port}$url';
    }
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: Theme.of(context).colorScheme.surface, child: const Center(child: CircularProgressIndicator()));
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 36),
                const SizedBox(height: 8),
                Text('Erro ao carregar imagem', style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)))
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            aula.titulo,
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        if (aula.categoria != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accent.withOpacity(0.5)),
            ),
            child: Text(
              aula.categoria!['nome'],
              style: AppTypography.caption.copyWith(color: _accent, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconText(context, Icons.timer, '${aula.duracao} min'),
        const SizedBox(height: 4),
        if (aula.agendamento != null) ...[
          if (aula.agendamento!.recorrente)
            _buildIconText(context, Icons.repeat, _formatRecurrence(aula.agendamento!))
          else if (aula.agendamento!.dataExata != null)
            _buildIconText(context, Icons.calendar_today, _formatExactDate(aula.agendamento!.dataExata!)),

          if (aula.agendamento!.horarioRecorrente != null)
             _buildIconText(context, Icons.access_time, _formatTime(aula.agendamento!.horarioRecorrente!))
          else if (aula.agendamento!.dataExata != null)
             _buildIconText(context, Icons.access_time, _formatTimeFromDate(aula.agendamento!.dataExata!)),
        ],
      ],
    );
  }



  Widget _buildIconText(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 8),
        Text(text, style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
      ],
    );
  }

  String _formatRecurrence(AgendamentoResponse ag) {
    List<String> days = [];
    if (ag.segunda == true) days.add('Seg');
    if (ag.terca == true) days.add('Ter');
    if (ag.quarta == true) days.add('Qua');
    if (ag.quinta == true) days.add('Qui');
    if (ag.sexta == true) days.add('Sex');
    if (ag.sabado == true) days.add('Sáb');
    if (ag.domingo == true) days.add('Dom');
    
    if (days.isEmpty) return 'Recorrente';
    return days.join(', ');
  }

  String _formatExactDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _formatTimeFromDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
