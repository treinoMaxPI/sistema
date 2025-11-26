import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import '../../widgets/modal_components.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import '../../theme/typography.dart';
import '../../services/aula_service.dart';

class PersonalAulasPage extends StatefulWidget {
  const PersonalAulasPage({super.key});

  @override
  State<PersonalAulasPage> createState() => _PersonalAulasPageState();
}

class _PersonalAulasPageState extends State<PersonalAulasPage> {
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
    final resp = await _aulaService.listar();
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

  void _abrirNovaAula() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NovaAulaSheet(
        onSalvar: (titulo, descricao, imagemUrl) async {
          final resp = await _aulaService.criar(CriarAulaRequest(titulo: titulo, descricao: descricao, imagemUrl: imagemUrl));
          if (!resp.success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(resp.message ?? 'Erro ao criar aula')),
              );
            }
          }
          await _carregarAulas();
        },
      ),
    );
  }

  void _editarAula(int index) {
    final original = _aulas[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NovaAulaSheet(
        initialTitulo: original.titulo,
        initialMensagem: original.descricao,
        initialImagemUrl: original.imagemUrl,
        onSalvar: (titulo, descricao, imagemUrl) async {
          final resp = await _aulaService.atualizar(original.id, AtualizarAulaRequest(titulo: titulo, descricao: descricao, imagemUrl: imagemUrl));
          if (!resp.success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(resp.message ?? 'Erro ao atualizar aula')),
              );
            }
          }
          await _carregarAulas();
        },
      ),
    );
  }

  Future<void> _removerAula(int index) async {
    final id = _aulas[index].id;
    final resp = await _aulaService.excluir(id);
    if (!resp.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message ?? 'Erro ao excluir aula')),
        );
      }
    }
    await _carregarAulas();
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
        title: const Text('Aulas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF312E),
        foregroundColor: Colors.white,
        onPressed: _abrirNovaAula,
        icon: const Icon(Icons.add),
        label: const Text('Nova Aula'),
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
                    ? _EmptyStateAulas(onCreate: _abrirNovaAula)
                    : ListView.separated(
                        itemCount: _aulas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final a = _aulas[index];
                          return _AulaCard(
                            aula: a,
                            onEdit: () => _editarAula(index),
                            onDelete: () => _removerAula(index),
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
  final VoidCallback onCreate;

  const _EmptyStateAulas({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, color: Colors.grey, size: 48),
          const SizedBox(height: 8),
          Text('Sem aulas por enquanto', style: AppTypography.bodyLarge),
          const SizedBox(height: 8),
          Text('Clique em “Nova Aula” para criar a primeira aula.', style: AppTypography.caption),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF312E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Nova Aula'),
          ),
        ],
      ),
    );
  }
}

class _NovaAulaSheet extends StatefulWidget {
  final void Function(String titulo, String descricao, String? imagemUrl) onSalvar;
  final String? initialTitulo;
  final String? initialMensagem;
  final String? initialImagemUrl;

  const _NovaAulaSheet({required this.onSalvar, this.initialTitulo, this.initialMensagem, this.initialImagemUrl});

  @override
  State<_NovaAulaSheet> createState() => _NovaAulaSheetState();
}

class _NovaAulaSheetState extends State<_NovaAulaSheet> {
  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  final AulaService _service = AulaService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.initialTitulo);
    _descricaoController = TextEditingController(text: widget.initialMensagem);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nova Aula', style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _tituloController,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: AppTypography.bodySmall.copyWith(color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descricaoController,
              maxLines: 5,
              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Descrição',
                labelStyle: AppTypography.bodySmall.copyWith(color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[800]!),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ImagePickerRow(
              pickedBytes: _pickedBytes,
              pickedFilename: _pickedFilename,
              onPick: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                if (result != null && result.files.isNotEmpty) {
                  final f = result.files.first;
                  if (f.bytes != null) {
                    const int maxBytes = 5 * 1024 * 1024;
                    if (f.size > maxBytes) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arquivo muito grande. Tamanho máximo: 5MB.')));
                      }
                      return;
                    }
                    setState(() {
                      _pickedBytes = f.bytes!;
                      _pickedFilename = f.name;
                    });
                  }
                }
              },
              onRemove: () => setState(() {
                _pickedBytes = null;
                _pickedFilename = null;
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[700]!),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final titulo = _tituloController.text.trim();
                      final descricao = _descricaoController.text.trim();
                      if (titulo.isEmpty || descricao.isEmpty) return;
                      setState(() => _saving = true);
                      String? finalUrl;
                      if (_pickedBytes != null && _pickedFilename != null) {
                        final up = await _service.uploadImagem(_pickedBytes!, _pickedFilename!);
                        if (up.success && up.data != null) finalUrl = up.data;
                        else {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(up.message ?? 'Erro ao enviar imagem')));
                        }
                      }
                      widget.onSalvar(titulo, descricao, finalUrl);
                      if (mounted) Navigator.pop(context);
                      setState(() => _saving = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF312E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerRow extends StatelessWidget {
  final Uint8List? pickedBytes;
  final String? pickedFilename;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerRow({required this.pickedBytes, required this.pickedFilename, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onPick,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              icon: const Icon(Icons.image, color: Colors.white),
              label: const Text('Adicionar imagem'),
            ),
            const SizedBox(width: 12),
            if (pickedBytes != null)
              OutlinedButton.icon(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[700]!),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text('Remover'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (pickedBytes != null) _ResponsiveImagePreview(bytes: pickedBytes!),
      ],
    );
  }
}

class _ResponsiveImagePreview extends StatelessWidget {
  final Uint8List bytes;
  const _ResponsiveImagePreview({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        double ar = _aspectForWidth(w);
        final double desiredHeight = w / ar;
        final double maxPreviewHeight = 160;
        final double height = math.min(desiredHeight, maxPreviewHeight);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: Text('Falha ao pré-visualizar imagem', style: AppTypography.caption),
                );
              },
            ),
          ),
        );
      },
    );
  }

  double _aspectForWidth(double w) {
    if (w < 480) return 4 / 5;
    if (w < 800) return 3 / 4;
    return 16 / 9;
  }
}

class _AulaCard extends StatelessWidget {
  final AulaResponse aula;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) formatDate;

  const _AulaCard({required this.aula, required this.onEdit, required this.onDelete, required this.formatDate});

  Color get _cardColor => const Color(0xFF121212);
  Color get _borderColor => const Color(0xFF1E1E1E);
  Color get _accent => const Color(0xFFFF312E);

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
            const SizedBox(height: 8),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  bool get _hasImage => (aula.imagemUrl != null && aula.imagemUrl!.trim().isNotEmpty);

  Widget _buildHeader(BuildContext context) {
    final String initials = _initialsFrom(aula.titulo);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey[800],
          child: Text(initials, style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(aula.titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodyLarge),
                  ),
                ],
              ),
              Text(formatDate(aula.dataCriacao), style: AppTypography.caption),
            ],
          ),
        ),
        PopupMenuButton<int>(
          color: _cardColor,
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onSelected: (val) {
            if (val == 1) onEdit();
            else if (val == 2) {
              showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar exclusão'),
                  content: const Text('Você deseja confirmar essa exclusão?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
                  ],
                ),
              ).then((confirmed) { if (confirmed == true) onDelete(); });
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<int>(value: 1, child: Row(children: [Icon(Icons.edit, color: Colors.white), SizedBox(width: 8), Text('Editar')])),
            const PopupMenuItem<int>(value: 2, child: Row(children: [Icon(Icons.delete, color: Colors.white), SizedBox(width: 8), Text('Excluir')])),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    String url = aula.imagemUrl!;
    if (url.startsWith('/')) {
      final uri = Uri.parse(AulaService.baseUrl);
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
                return Container(color: Colors.black, child: const Center(child: CircularProgressIndicator()));
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.broken_image, color: Colors.white54, size: 36), const SizedBox(height: 8), Text('Falha ao carregar imagem (arquivo muito grande ou inválido)', style: AppTypography.caption)]),
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
    return Text(aula.descricao, style: AppTypography.bodyMedium);
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        IconButton(tooltip: 'Editar', onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.white)),
        IconButton(tooltip: 'Excluir', onPressed: onDelete, icon: Icon(Icons.delete, color: _accent)),
      ],
    );
  }

  String _initialsFrom(String text) {
    final parts = text.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'A';
    final first = parts.first.characters.take(1).toString().toUpperCase();
    String second = '';
    if (parts.length > 1) second = parts[1].characters.take(1).toString().toUpperCase();
    return (first + second).trim();
  }

  double _aspectForWidth(double w) {
    if (w < 480) return 4 / 5;
    if (w < 800) return 3 / 4;
    return 16 / 9;
  }
}
