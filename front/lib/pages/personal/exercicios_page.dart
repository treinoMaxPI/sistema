import 'package:flutter/material.dart';
import '../../services/exercicio_service.dart';
import '../../models/exercicio.dart';
import '../../models/grupo_muscular.dart';
import '../../widgets/modal_components.dart';

class ExerciciosPage extends StatefulWidget {
  const ExerciciosPage({super.key});

  @override
  State<ExerciciosPage> createState() => _ExerciciosPageState();
}

class _ExerciciosPageState extends State<ExerciciosPage> {
  final ExercicioService _exercicioService = ExercicioService();
  List<Exercicio> _exercicios = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _carregarExercicios();
  }

  Future<void> _carregarExercicios() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _exercicioService.listarTodos();

    if (response.success && response.data != null) {
      setState(() {
        _exercicios = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Erro ao carregar exercícios';
        _isLoading = false;
      });
    }
  }

  void _showCriarExercicioDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CriarExercicioDialog(
        onExercicioCriado: _carregarExercicios,
      ),
    );
  }

  void _showEditarExercicioDialog(Exercicio exercicio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditarExercicioDialog(
        exercicio: exercicio,
        onExercicioAtualizado: _carregarExercicios,
      ),
    );
  }

  void _showDeletarExercicioDialog(Exercicio exercicio) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirmar Exclusão',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir o exercício "${exercicio.nome}"? Esta ação não pode ser desfeita.',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletarExercicio(exercicio);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletarExercicio(Exercicio exercicio) async {
    final response = await _exercicioService.deletarExercicio(exercicio.id);

    if (response.success) {
      _carregarExercicios();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercício excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao excluir exercício'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Exercicio> get _exerciciosFiltrados {
    if (_searchQuery.isEmpty) {
      return _exercicios;
    }
    return _exercicios.where((exercicio) {
      final nome = exercicio.nome.toLowerCase();
      final gruposMusculares = exercicio.grupoMuscularDisplay.toLowerCase();
      final descricao = exercicio.descricao?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return nome.contains(query) ||
          gruposMusculares.contains(query) ||
          descricao.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gerenciar Exercícios',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCriarExercicioDialog,
        backgroundColor: const Color(0xFFFF312E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar exercícios...',
                hintStyle:
                    TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search,
                    color: colorScheme.onSurface.withOpacity(0.5)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: colorScheme.onSurface.withOpacity(0.5)),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.brightness == Brightness.light
                    ? Colors.white
                    : colorScheme.surface,
                hoverColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF312E),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
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
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _carregarExercicios,
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
                    : _exerciciosFiltrados.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty
                                      ? Icons.search_off
                                      : Icons.fitness_center,
                                  size: 64,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Nenhum exercício encontrado'
                                      : 'Nenhum exercício cadastrado',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Tente buscar com outros termos'
                                      : 'Adicione seu primeiro exercício',
                                  style: TextStyle(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _carregarExercicios,
                            color: const Color(0xFFFF312E),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              itemCount: _exerciciosFiltrados.length,
                              itemBuilder: (context, index) {
                                final exercicio = _exerciciosFiltrados[index];
                                return _ExercicioCard(
                                  exercicio: exercicio,
                                  onEditar: () =>
                                      _showEditarExercicioDialog(exercicio),
                                  onDeletar: () =>
                                      _showDeletarExercicioDialog(exercicio),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ExercicioCard extends StatelessWidget {
  final Exercicio exercicio;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  const _ExercicioCard({
    required this.exercicio,
    required this.onEditar,
    required this.onDeletar,
  });

  Color _getGrupoMuscularColor(List<String> gruposMusculares) {
    if (gruposMusculares.isEmpty) return const Color(0xFFFF312E);

    final grupo = gruposMusculares.first.toLowerCase();
    if (grupo.contains('peito') || grupo.contains('peitoral')) {
      return Colors.red;
    } else if (grupo.contains('costas') || grupo.contains('dorsal')) {
      return Colors.blue;
    } else if (grupo.contains('perna') || grupo.contains('quadríceps')) {
      return Colors.green;
    } else if (grupo.contains('braço') ||
        grupo.contains('bíceps') ||
        grupo.contains('tríceps')) {
      return Colors.orange;
    } else if (grupo.contains('ombro') || grupo.contains('deltoide')) {
      return Colors.purple;
    } else if (grupo.contains('abdômen') || grupo.contains('core')) {
      return Colors.teal;
    }
    return const Color(0xFFFF312E);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final grupoColor = _getGrupoMuscularColor(exercicio.grupoMuscular);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: grupoColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: grupoColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Mostrar detalhes do exercício
            _showDetalhesDialog(context);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícone do grupo muscular
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: grupoColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: grupoColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nome e grupo muscular
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercicio.nome,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: grupoColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercicio.grupoMuscularDisplay.toUpperCase(),
                              style: TextStyle(
                                color: grupoColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botões de ação
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      color: colorScheme.surface,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'editar') {
                          onEditar();
                        } else if (value == 'deletar') {
                          onDeletar();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              const Icon(Icons.edit,
                                  color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text('Editar',
                                  style:
                                      TextStyle(color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'deletar',
                          child: Row(
                            children: [
                              const Icon(Icons.delete,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text('Excluir',
                                  style:
                                      TextStyle(color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Descrição
                if (exercicio.descricao != null &&
                    exercicio.descricao!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    exercicio.descricao!,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                // Video URL
                if (exercicio.videoUrl != null &&
                    exercicio.videoUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        color: Color(0xFFFF312E),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Vídeo disponível',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetalhesDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getGrupoMuscularColor(exercicio.grupoMuscular)
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.fitness_center,
                color: _getGrupoMuscularColor(exercicio.grupoMuscular),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                exercicio.nome,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getGrupoMuscularColor(exercicio.grupoMuscular)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercicio.grupoMuscularDisplay.toUpperCase(),
                  style: TextStyle(
                    color: _getGrupoMuscularColor(exercicio.grupoMuscular),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (exercicio.descricao != null &&
                  exercicio.descricao!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Descrição',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercicio.descricao!,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
              if (exercicio.videoUrl != null &&
                  exercicio.videoUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Vídeo',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    // Abrir URL do vídeo
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.play_circle_filled,
                        color: Color(0xFFFF312E),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          exercicio.videoUrl!,
                          style: const TextStyle(
                            color: Color(0xFFFF312E),
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onEditar();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF312E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}

class CriarExercicioDialog extends StatefulWidget {
  final VoidCallback onExercicioCriado;

  const CriarExercicioDialog({super.key, required this.onExercicioCriado});

  @override
  State<CriarExercicioDialog> createState() => _CriarExercicioDialogState();
}

class _CriarExercicioDialogState extends State<CriarExercicioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _videoUrlController = TextEditingController();
  bool _isLoading = false;
  List<String> _gruposSelecionados = [];

  // Usa o enum do backend para garantir consistência
  List<String> get _gruposMusculares => GrupoMuscular.allAsString;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _criarExercicio() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;

    setState(() {
      _isLoading = true;
    });

    final request = CriarExercicioRequest(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      grupoMuscular: _gruposSelecionados,
      videoUrl: _videoUrlController.text.trim().isEmpty
          ? null
          : _videoUrlController.text.trim(),
    );

    final response = await ExercicioService().criarExercicio(request);

    if (response.success) {
      if (mounted) {
        Navigator.pop(context);
        widget.onExercicioCriado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercício criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao criar exercício'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ModalSheet(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF312E).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFFFF312E),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Criar Novo Exercício',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Nome do Exercício *',
                  labelStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.light
                      ? Colors.white
                      : colorScheme.surface,
                  hoverColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  if (value.trim().length > 100) {
                    return 'Nome deve ter no máximo 100 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Grupos Musculares *',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gruposMusculares.map((grupo) {
                  final isSelected = _gruposSelecionados.contains(grupo);
                  return FilterChip(
                    label: Text(grupo),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _gruposSelecionados.add(grupo);
                        } else {
                          _gruposSelecionados.remove(grupo);
                        }
                      });
                    },
                    backgroundColor: colorScheme.surface,
                    selectedColor: const Color(0xFFFF312E).withOpacity(0.2),
                    checkmarkColor: const Color(0xFFFF312E),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF312E)
                          : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFFF312E)
                          : colorScheme.outline,
                      width: 1.5,
                    ),
                  );
                }).toList(),
              ),
              if (_gruposSelecionados.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selecione pelo menos um grupo muscular',
                    style: TextStyle(color: Colors.red[300], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                style: TextStyle(color: colorScheme.onSurface),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.light
                      ? Colors.white
                      : colorScheme.surface,
                  hoverColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.trim().length > 500) {
                    return 'Descrição deve ter no máximo 500 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoUrlController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'URL do Vídeo',
                  labelStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.light
                      ? Colors.white
                      : colorScheme.surface,
                  hoverColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                  prefixIcon: Icon(Icons.play_circle_outline,
                      color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length > 255) {
                      return 'URL deve ter no máximo 255 caracteres';
                    }
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme) {
                      return 'URL inválida';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isLoading || _gruposSelecionados.isEmpty)
                          ? null
                          : _criarExercicio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF312E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Criar Exercício'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditarExercicioDialog extends StatefulWidget {
  final Exercicio exercicio;
  final VoidCallback onExercicioAtualizado;

  const EditarExercicioDialog({
    super.key,
    required this.exercicio,
    required this.onExercicioAtualizado,
  });

  @override
  State<EditarExercicioDialog> createState() => _EditarExercicioDialogState();
}

class _EditarExercicioDialogState extends State<EditarExercicioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _videoUrlController = TextEditingController();
  bool _isLoading = false;
  List<String> _gruposSelecionados = [];

  // Usa o enum do backend para garantir consistência
  List<String> get _gruposMusculares => GrupoMuscular.allAsString;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.exercicio.nome;
    _descricaoController.text = widget.exercicio.descricao ?? '';
    _gruposSelecionados = List.from(widget.exercicio.grupoMuscular);
    _videoUrlController.text = widget.exercicio.videoUrl ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _atualizarExercicio() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;

    setState(() {
      _isLoading = true;
    });

    final request = AtualizarExercicioRequest(
      nome: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      grupoMuscular: _gruposSelecionados,
      videoUrl: _videoUrlController.text.trim().isEmpty
          ? null
          : _videoUrlController.text.trim(),
    );

    final response = await ExercicioService()
        .atualizarExercicio(widget.exercicio.id, request);

    if (response.success) {
      if (mounted) {
        Navigator.pop(context);
        widget.onExercicioAtualizado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercício atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao atualizar exercício'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ModalSheet(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Editar Exercício',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Nome do Exercício *',
                  labelStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.light
                      ? Colors.white
                      : colorScheme.surface,
                  hoverColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  if (value.trim().length > 100) {
                    return 'Nome deve ter no máximo 100 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Grupos Musculares *',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gruposMusculares.map((grupo) {
                  final isSelected = _gruposSelecionados.contains(grupo);
                  return FilterChip(
                    label: Text(grupo),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _gruposSelecionados.add(grupo);
                        } else {
                          _gruposSelecionados.remove(grupo);
                        }
                      });
                    },
                    backgroundColor: colorScheme.surface,
                    selectedColor: const Color(0xFFFF312E).withOpacity(0.2),
                    checkmarkColor: const Color(0xFFFF312E),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF312E)
                          : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFFF312E)
                          : colorScheme.outline,
                      width: 1.5,
                    ),
                  );
                }).toList(),
              ),
              if (_gruposSelecionados.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selecione pelo menos um grupo muscular',
                    style: TextStyle(color: Colors.red[300], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                style: TextStyle(color: colorScheme.onSurface),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.light
                      ? Colors.white
                      : colorScheme.surface,
                  hoverColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.trim().length > 500) {
                    return 'Descrição deve ter no máximo 500 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoUrlController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'URL do Vídeo',
                  labelStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: theme.brightness == Brightness.light
                      ? Colors.white
                      : colorScheme.surface,
                  hoverColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFFFF312E)),
                  ),
                  prefixIcon: Icon(Icons.play_circle_outline,
                      color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length > 255) {
                      return 'URL deve ter no máximo 255 caracteres';
                    }
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasScheme) {
                      return 'URL inválida';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isLoading || _gruposSelecionados.isEmpty)
                          ? null
                          : _atualizarExercicio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF312E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Salvar Alterações'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
