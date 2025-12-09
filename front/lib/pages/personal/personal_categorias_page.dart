import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:characters/characters.dart';
import '../../theme/typography.dart';
import '../../widgets/modal_components.dart';
import '../../models/categoria.dart';
import '../../models/plano.dart';
import '../../services/categoria_service.dart';
import '../../services/plano_service.dart';

class PersonalCategoriasPage extends StatefulWidget {
  const PersonalCategoriasPage({super.key});

  @override
  State<PersonalCategoriasPage> createState() => _PersonalCategoriasPageState();
}

class _PersonalCategoriasPageState extends State<PersonalCategoriasPage> {
  final CategoriaService _service = CategoriaService(baseUrl: 'http://localhost:8080');
  List<Categoria> _categorias = [];
  List<PlanoResponse> _planos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> _carregarCategorias() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _getToken();
  final list = await _service.listarTodas(token);
  // carregar planos disponíveis (apenas uma vez)
      final planosResp = await PlanoService().listarPlanos();
      setState(() {
        if (planosResp.success && planosResp.data != null) _planos = planosResp.data!;
        _categorias = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _abrirNovaCategoria({Categoria? initial}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NovaCategoriaSheet(
        initialNome: initial?.nome,
  initialPlanosIds: initial?.planos?.where((p) => p.id != null).map((p) => p.id!).toList(),
        planos: _planos,
  onSalvar: (nome, {List<String>? planosIds}) async {
          final token = await _getToken();
          if (token == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token de acesso não encontrado')));
            }
            return;
          }

          try {
            if (initial == null) {
              final selectedPlanos = planosIds != null 
                  ? _planos.where((p) => planosIds.contains(p.id)).map((p) => Plano(
                      id: p.id, 
                      nome: p.nome, 
                      descricao: p.descricao, 
                      ativo: p.ativo, 
                      precoCentavos: p.precoCentavos
                    )).toList() 
                  : <Plano>[];
              await _service.criar(Categoria(nome: nome, planos: selectedPlanos), token);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Categoria criada com sucesso!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
            } else {
              final selectedPlanos = planosIds != null 
                  ? _planos.where((p) => planosIds.contains(p.id)).map((p) => Plano(
                      id: p.id, 
                      nome: p.nome, 
                      descricao: p.descricao, 
                      ativo: p.ativo, 
                      precoCentavos: p.precoCentavos
                    )).toList() 
                  : <Plano>[];
              await _service.atualizar(initial.id ?? '', Categoria(id: initial.id, nome: nome, planos: selectedPlanos), token);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Categoria atualizada com sucesso!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
            }
            await _carregarCategorias();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _removerCategoria(Categoria cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta categoria?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await _getToken();
      if (token == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Token de acesso não encontrado')));
        return;
      }
      await _service.deletar(cat.id ?? '', token);
      await _carregarCategorias();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Categoria deletada com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _mostrarDetalhesCategoria(Categoria c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(c.nome, style: AppTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.planos != null && c.planos!.isNotEmpty) ...[
              Text('Planos vinculados:', style: AppTypography.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: c.planos!.map((p) => Chip(
                  label: Text(p.nome, style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFFFF312E),
                  side: BorderSide.none,
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (c.dataCriacao != null)
              Text('Criado em: ${_formatDate(c.dataCriacao!)}', style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fechar', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return date;
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
        title: const Text('Categorias'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        onPressed: () => _abrirNovaCategoria(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Categoria'),
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
                : _categorias.isEmpty
                    ? _EmptyStateCategorias(onCreate: () => _abrirNovaCategoria())
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _categorias.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = _categorias[index];
                          return _CategoriaCard(
                            categoria: c,
                            onEdit: () => _abrirNovaCategoria(initial: c),
                            onDelete: () => _removerCategoria(c),
                            onTap: () => _mostrarDetalhesCategoria(c),
                          );
                        },
                      )),
      ),
    );
  }
}

class _EmptyStateCategorias extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyStateCategorias({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), size: 48),
          const SizedBox(height: 8),
          Text('Sem categorias por enquanto', style: AppTypography.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text('Clique em "Nova Categoria" para criar a primeira.', style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF312E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Nova Categoria'),
          ),
        ],
      ),
    );
  }
}

class _NovaCategoriaSheet extends StatefulWidget {
  final Future<void> Function(String nome, {List<String>? planosIds}) onSalvar;
  final List<PlanoResponse> planos;
  final List<String>? initialPlanosIds;
  final String? initialNome;
  const _NovaCategoriaSheet({required this.onSalvar, this.initialNome, required this.planos, this.initialPlanosIds});

  @override
  State<_NovaCategoriaSheet> createState() => _NovaCategoriaSheetState();
}

class _NovaCategoriaSheetState extends State<_NovaCategoriaSheet> {
  late final TextEditingController _nomeController;
  bool _saving = false;
  List<String> _selectedPlanosLocal = [];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.initialNome);
  if (widget.initialPlanosIds != null) _selectedPlanosLocal = List.from(widget.initialPlanosIds!);
  }

  @override
  void dispose() {
    _nomeController.dispose();
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
            Text(widget.initialNome == null ? 'Nova Categoria' : 'Editar Categoria', style: AppTypography.titleLarge.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 16),
            TextField(
              controller: _nomeController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              cursorColor: const Color(0xFFFF312E),
              decoration: InputDecoration(
                labelText: 'Nome',
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
            if (widget.planos.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.planos.map((p) {
                  final selected = _selectedPlanosLocal.contains(p.id);
                  return FilterChip(
                    label: Text(p.nome),
                    selected: selected,
                    onSelected: (on) => setState(() {
                      if (on) {
                        _selectedPlanosLocal.add(p.id);
                      } else {
                        _selectedPlanosLocal.remove(p.id);
                      }
                    }),
                  );
                }).toList(),
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
                      final nome = _nomeController.text.trim();
                      if (nome.isEmpty) return;
                      setState(() => _saving = true);
                      await widget.onSalvar(nome, planosIds: _selectedPlanosLocal.isNotEmpty ? _selectedPlanosLocal : null);
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

class _CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _CategoriaCard({required this.categoria, required this.onEdit, required this.onDelete, required this.onTap});

  Color _cardColor(BuildContext context) => Theme.of(context).colorScheme.surface;
  Color _borderColor(BuildContext context) => Theme.of(context).colorScheme.outline;
  Color get _accent => const Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final hasPlanos = categoria.planos != null && categoria.planos!.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasPlanos ? _accent : _borderColor(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Text(
                    categoria.nome,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              if (hasPlanos)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${categoria.planos!.length} ${categoria.planos!.length == 1 ? 'plano' : 'planos'}',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasPlanos) ...[
            Text('Planos vinculados:', style: AppTypography.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoria.planos!.map((p) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accent.withOpacity(0.3)),
                ),
                child: Text(
                  p.nome,
                  style: AppTypography.caption.copyWith(color: _accent),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Text(
              'Nenhum plano vinculado',
              style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                color: Colors.blue,
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete,
                color: Colors.red,
                onPressed: () {
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
                },
                tooltip: 'Excluir',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}
