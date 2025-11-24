import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/typography.dart';
import '../../services/mural_service.dart';

class CustomerMuralPage extends StatefulWidget {
  const CustomerMuralPage({super.key});

  @override
  State<CustomerMuralPage> createState() => _CustomerMuralPageState();
}

class _CustomerMuralPageState extends State<CustomerMuralPage> {
  final MuralService _muralService = MuralService();
  List<ComunicadoResponse> _comunicados = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarComunicados();
  }

  Future<void> _carregarComunicados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final resp = await _muralService.listar(all: false);
    if (resp.success && resp.data != null) {
      setState(() {
        _comunicados = resp.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = resp.message ?? 'Erro ao carregar comunicados';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mural da Academia'),
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
                : _comunicados.isEmpty
            ? const _EmptyStateReadOnly()
            : ListView.separated(
                itemCount: _comunicados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final c = _comunicados[index];
                  return _ReadOnlyPostCard(
                    comunicado: c,
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

class _EmptyStateReadOnly extends StatelessWidget {
  const _EmptyStateReadOnly();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign, color: Colors.grey, size: 48),
          const SizedBox(height: 8),
          Text(
            'Nenhum comunicado disponível',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Volte mais tarde para ver novidades.',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyPostCard extends StatelessWidget {
  final ComunicadoResponse comunicado;
  final String Function(String) formatDate;

  const _ReadOnlyPostCard({
    required this.comunicado,
    required this.formatDate,
  });

  Color _cardColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _borderColor(BuildContext context) => Theme.of(context).colorScheme.outline;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _cardColor(context),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _borderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            if (_hasImage) ...[
              const SizedBox(height: 10),
              _buildImage(context),
            ],
            const SizedBox(height: 10),
            _buildBody(context),
            const SizedBox(height: 8),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  bool get _hasImage => (comunicado.imagemUrl != null && comunicado.imagemUrl!.trim().isNotEmpty);

  Widget _buildHeader(BuildContext context) {
    final String initials = _initialsFrom((comunicado.autorNome ?? '').trim().isEmpty ? 'A' : comunicado.autorNome!);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Text(
            initials,
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comunicado.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLarge,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (comunicado.autorNome != null)
                    Text(
                      comunicado.autorNome!,
                      style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    ),
                ],
              ),
              Text(
                formatDate(comunicado.dataCriacao),
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _initialsFrom(String text) {
    final parts = text.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'A';
    String first = parts.first.substring(0, 1).toUpperCase();
    String second = '';
    if (parts.length > 1) {
      second = parts[1].substring(0, 1).toUpperCase();
    }
    return (first + second).trim();
  }

  Widget _buildImage(BuildContext context) {
    String url = comunicado.imagemUrl!;
    if (url.startsWith('/')) {
      final uri = Uri.parse(MuralService.baseUrl);
      url = '${uri.scheme}://${uri.host}:${uri.port}$url';
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        double ar = _aspectForWidth(w);
        final double desiredHeight = w / ar;
        final double maxFeedHeight = 300;
        final double height = math.min(desiredHeight, maxFeedHeight);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image, color: Colors.white54, size: 36),
                        const SizedBox(height: 8),
                        Text('Falha ao carregar imagem', style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Text(
      comunicado.mensagem,
      style: AppTypography.bodyMedium,
    );
  }

  Widget _buildActions(BuildContext context) {
    final service = MuralService();
    return Row(
      children: [
        FutureBuilder<List<dynamic>>(
          future: () async {
            final liked = await service.hasLiked(comunicado.id);
            final count = await service.getLikesCount(comunicado.id);
            return [liked, count];
          }(),
          builder: (context, snapshot) {
            bool liked = false;
            int count = 0;
            if (snapshot.hasData) {
              liked = snapshot.data![0] as bool;
              count = snapshot.data![1] as int;
            }
            return StatefulBuilder(
              builder: (context, setStateSB) => Row(
                children: [
                  IconButton(
                    tooltip: liked ? 'Descurtir' : 'Curtir',
                    onPressed: () async {
                      final newCount = await service.toggleLike(comunicado.id);
                      final newLiked = await service.hasLiked(comunicado.id);
                      setStateSB(() {
                        count = newCount;
                        liked = newLiked;
                      });
                    },
                    icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? const Color(0xFFFF312E) : Theme.of(context).colorScheme.onSurface),
                  ),
                  Text('$count', style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  double _aspectForWidth(double w) {
    if (w < 480) return 4 / 5;
    if (w < 800) return 3 / 4;
    return 16 / 9;
  }
}