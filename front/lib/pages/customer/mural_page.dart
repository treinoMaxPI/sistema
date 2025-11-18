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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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

  Color get _cardColor => const Color(0xFF121212);
  Color get _borderColor => const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _borderColor),
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
          ],
        ),
      ),
    );
  }

  bool get _hasImage => (comunicado.imagemUrl != null && comunicado.imagemUrl!.trim().isNotEmpty);

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.campaign, color: Color(0xFF2196F3)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comunicado.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLarge,
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
                  color: Colors.black,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.broken_image, color: Colors.white54, size: 36),
                        const SizedBox(height: 8),
                        Text('Falha ao carregar imagem', style: AppTypography.caption),
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

  double _aspectForWidth(double w) {
    if (w < 480) return 4 / 5;
    if (w < 800) return 3 / 4;
    return 16 / 9;
  }
}