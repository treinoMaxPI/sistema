import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import '../../widgets/modal_components.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import '../../theme/typography.dart';
import '../../services/mural_service.dart';
import '../../services/auth_service.dart';

class PersonalMuralPage extends StatefulWidget {
  const PersonalMuralPage({super.key});

  @override
  State<PersonalMuralPage> createState() => _PersonalMuralPageState();
}

class _PersonalMuralPageState extends State<PersonalMuralPage> {
  final MuralService _muralService = MuralService();
  List<ComunicadoResponse> _comunicados = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userName;

  @override
  void initState() {
    super.initState();
    AuthService().getUserName().then((value){ if(mounted) setState(()=> _userName = value); });
    _carregarComunicados();
  }

  Future<void> _carregarComunicados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final resp = await _muralService.listar(all: true);
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

  void _abrirNovoComunicado() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NovoComunicadoSheet(
        onSalvar: (titulo, mensagem, publicado, imagemUrl) async {
          final resp = await _muralService
              .criar(CriarComunicadoRequest(
            titulo: titulo,
            mensagem: mensagem,
            publicado: publicado,
            imagemUrl: imagemUrl,
          ));
          if (!resp.success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(resp.message ?? 'Erro ao criar comunicado')),
              );
            }
          }
          await _carregarComunicados();
        },
      ),
    );
  }

  void _editarComunicado(int index) {
    final original = _comunicados[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NovoComunicadoSheet(
        initialTitulo: original.titulo,
        initialMensagem: original.mensagem,
        initialPublicado: original.publicado,
        initialImagemUrl: original.imagemUrl,
        onSalvar: (titulo, mensagem, publicado, imagemUrl) async {
          final resp = await _muralService
              .atualizar(
            original.id,
            AtualizarComunicadoRequest(
              titulo: titulo,
              mensagem: mensagem,
              imagemUrl: imagemUrl,
            ),
          );
          if (!resp.success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(resp.message ?? 'Erro ao atualizar comunicado')),
              );
            }
          }
          if (publicado != original.publicado) {
            await _muralService.alterarStatus(original.id, publicado);
          }
          await _carregarComunicados();
        },
      ),
    );
  }

  Future<void> _removerComunicado(int index) async {
    final id = _comunicados[index].id;
    final resp = await _muralService.excluir(id);
    if (!resp.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message ?? 'Erro ao excluir comunicado')),
        );
      }
    }
    await _carregarComunicados();
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        onPressed: _abrirNovoComunicado,
        icon: const Icon(Icons.add),
        label: const Text('Postar no Mural'),
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
            ? _EmptyState(onCreate: _abrirNovoComunicado)
            : ListView.separated(
                itemCount: _comunicados.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final c = _comunicados[index];
                  return _FeedPostCard(
                    comunicado: c,
                    onTogglePublish: () async {
                      await _muralService.alterarStatus(c.id, !c.publicado);
                      await _carregarComunicados();
                    },
                    onEdit: () => _editarComunicado(index),
                    onDelete: () => _removerComunicado(index),
                    formatDate: _formatDate,
                    posterName: _userName ?? c.autorNome,
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

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.campaign, color: Colors.grey, size: 48),
          const SizedBox(height: 8),
          Text(
            'Sem comunicados por enquanto',
            style: AppTypography.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Clique em “Postar no Mural” para criar o primeiro aviso.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Postar no Mural'),
          ),
        ],
      ),
    );
  }
}

class _NovoComunicadoSheet extends StatefulWidget {
  final void Function(String titulo, String mensagem, bool publicado, String? imagemUrl) onSalvar;
  final String? initialTitulo;
  final String? initialMensagem;
  final bool initialPublicado;
  final String? initialImagemUrl;

  const _NovoComunicadoSheet({
    required this.onSalvar,
    this.initialTitulo,
    this.initialMensagem,
    this.initialPublicado = true,
    this.initialImagemUrl,
  });

  @override
  State<_NovoComunicadoSheet> createState() => _NovoComunicadoSheetState();
}

class _NovoComunicadoSheetState extends State<_NovoComunicadoSheet> {
  late final TextEditingController _tituloController;
  late final TextEditingController _mensagemController;
  late bool _publicado;
  Uint8List? _pickedBytes;
  String? _pickedFilename;
  final MuralService _service = MuralService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.initialTitulo);
    _mensagemController = TextEditingController(text: widget.initialMensagem);
    _publicado = widget.initialPublicado;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensagemController.dispose();
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
          const Text(
            'Novo Comunicado',
            style: AppTypography.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tituloController,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            cursorColor: const Color(0xFF4CAF50),
            decoration: InputDecoration(
              labelText: 'Título',
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mensagemController,
            maxLines: 5,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            cursorColor: const Color(0xFF4CAF50),
            decoration: InputDecoration(
              labelText: 'Mensagem',
              labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Arquivo muito grande. Tamanho máximo: 5MB.')),
                      );
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
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                value: _publicado,
                onChanged: (v) => setState(() => _publicado = v),
                activeColor: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              Text(
                _publicado ? 'Publicar agora' : 'Salvar como rascunho',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.outline),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
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
                    final mensagem = _mensagemController.text.trim();
                    if (titulo.isEmpty || mensagem.isEmpty) return;
                    setState(() => _saving = true);
                    String? finalUrl;
                    if (_pickedBytes != null && _pickedFilename != null) {
                      final up = await _service.uploadImagem(_pickedBytes!, _pickedFilename!);
                      if (up.success && up.data != null) {
                        finalUrl = up.data;
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(up.message ?? 'Erro ao enviar imagem')),
                          );
                        }
                      }
                    }
                    widget.onSalvar(titulo, mensagem, _publicado, finalUrl);
                    if (mounted) Navigator.pop(context);
                    setState(() => _saving = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Salvar'),
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

  const _ImagePickerRow({
    required this.pickedBytes,
    required this.pickedFilename,
    required this.onPick,
    required this.onRemove,
  });

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
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              icon: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurface),
              label: const Text('Adicionar imagem'),
            ),
            const SizedBox(width: 12),
            if (pickedBytes != null)
              OutlinedButton.icon(
                onPressed: onRemove,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                label: const Text('Remover'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tamanho máximo: 5MB',
          style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
        const SizedBox(height: 8),
        if (pickedBytes != null)
          _ResponsiveImagePreview(bytes: pickedBytes!),
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

class _FeedPostCard extends StatelessWidget {
  final ComunicadoResponse comunicado;
  final VoidCallback onTogglePublish;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(String) formatDate;
  final String? posterName;

  const _FeedPostCard({
    required this.comunicado,
    required this.onTogglePublish,
    required this.onEdit,
    required this.onDelete,
    required this.formatDate,
    this.posterName,
  });

  Color _cardColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _borderColor(BuildContext context) => Theme.of(context).colorScheme.outline;  
  Color get _accent => const Color(0xFF4CAF50);

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
    final String initials = _initialsFrom(posterName ?? comunicado.titulo);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
                  if ((posterName ?? comunicado.autorNome) != null)
                    Text(
                      (posterName ?? comunicado.autorNome)!,
                      style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    ),
                  const SizedBox(width: 6),
                  if (!comunicado.publicado)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderColor(context)),
                      ),
                      child: Text('Rascunho', style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
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
        PopupMenuButton<int>(
          color: _cardColor(context),
          icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.onSurface),
          onSelected: (val) {
            if (val == 1) {
              onEdit();
            } else if (val == 2) {
              showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar exclusão'),
                  content: const Text('Você deseja confirmar essa exclusão?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              ).then((confirmed) {
                if (confirmed == true) {
                  onDelete();
                }
              });
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: [Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface), const SizedBox(width: 8), const Text('Editar')],
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: Row(
                children: [Icon(Icons.delete, color: Theme.of(context).colorScheme.onSurface), const SizedBox(width: 8), const Text('Excluir')],
              ),
            ),
          ],
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
            child: Stack(
              children: [
                Positioned.fill(
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
                              Text('Falha ao carregar imagem (arquivo muito grande ou inválido)', style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
        TextButton.icon(
          onPressed: onTogglePublish,
          icon: Icon(
            comunicado.publicado ? Icons.visibility : Icons.visibility_off,
            color: _accent,
          ),
          label: Text(
            comunicado.publicado ? 'Publicado' : 'Rascunho',
            style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
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
                    icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? const Color(0xFF4CAF50) : Theme.of(context).colorScheme.onSurface),
                  ),
                  Text('$count', style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            );
          },
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Editar',
          onPressed: onEdit,
          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface),
        ),
        IconButton(
          tooltip: 'Excluir',
          onPressed: onDelete,
          icon: Icon(Icons.delete, color: _accent),
        ),
      ],
    );
  }

  String _initialsFrom(String text) {
    final parts = text.trim().split(RegExp(r"\s+")).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'M';
    final first = parts.first.characters.take(1).toString().toUpperCase();
    String second = '';
    if (parts.length > 1) {
      second = parts[1].characters.take(1).toString().toUpperCase();
    }
    return (first + second).trim();
  }

  double _aspectForWidth(double w) {
    if (w < 480) return 4 / 5;
    if (w < 800) return 3 / 4;
    return 16 / 9;
  }

}
