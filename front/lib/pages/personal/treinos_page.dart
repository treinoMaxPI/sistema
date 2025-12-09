import 'package:flutter/material.dart';
import '../../services/treino_service.dart';
import '../../services/usuario_service.dart';
import '../../models/treino.dart';
import '../../widgets/treino_dialogs.dart';

class TreinosPage extends StatefulWidget {
  const TreinosPage({super.key});

  @override
  State<TreinosPage> createState() => _TreinosPageState();
}

class _TreinosPageState extends State<TreinosPage> {
  final TreinoService _treinoService = TreinoService();
  List<UsuarioModel> _usuarios = [];
  UsuarioModel? _usuarioSelecionado;
  List<Treino> _treinos = [];
  bool _isLoadingUsuarios = true;
  bool _isLoadingTreinos = false;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _isLoadingUsuarios = true;
      _errorMessage = null;
    });

    try {
      // Listar todos os usuários, não apenas os que têm treinos
      final usuarioService = UsuarioService();
      final response = await usuarioService.listarTodos();

      if (response.success && response.data != null) {
        debugPrint('Usuários carregados: ${response.data!.length}');
        setState(() {
          _usuarios = response.data!;
          _isLoadingUsuarios = false;
        });
      } else {
        debugPrint('Erro ao carregar usuários: ${response.message}');
        setState(() {
          _errorMessage = response.message ?? 'Erro ao carregar usuários';
          _isLoadingUsuarios = false;
        });
      }
    } catch (e) {
      debugPrint('Exceção ao carregar usuários: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar usuários: $e';
        _isLoadingUsuarios = false;
      });
    }
  }

  Future<void> _carregarTreinosDoUsuario(String usuarioId) async {
    setState(() {
      _isLoadingTreinos = true;
      _errorMessage = null;
    });

    final response = await _treinoService.listarTodos(usuarioId: usuarioId);

    if (response.success && response.data != null) {
      setState(() {
        _treinos = response.data!;
        _isLoadingTreinos = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Erro ao carregar treinos';
        _isLoadingTreinos = false;
      });
    }
  }

  void _selecionarUsuario(UsuarioModel usuario) {
    setState(() {
      _usuarioSelecionado = usuario;
      _treinos = [];
      _searchQuery = '';
    });
    _carregarTreinosDoUsuario(usuario.id);
  }

  void _voltarParaListaUsuarios() {
    setState(() {
      _usuarioSelecionado = null;
      _treinos = [];
      _searchQuery = '';
    });
  }

  void _showCriarTreinoDialog() {
    final usuarioId = _usuarioSelecionado?.id;
    if (usuarioId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CriarTreinoDialog(
        usuarioId: usuarioId,
        onTreinoCriado: () {
          _carregarTreinosDoUsuario(usuarioId);
        },
      ),
    );
  }

  void _criarTreinoParaUsuario(UsuarioModel usuario) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CriarTreinoDialog(
        usuarioId: usuario.id,
        onTreinoCriado: () {
          // Se o usuário já estava selecionado, recarregar treinos
          if (_usuarioSelecionado?.id == usuario.id) {
            _carregarTreinosDoUsuario(usuario.id);
          } else {
            // Caso contrário, selecionar o usuário e carregar treinos
            _selecionarUsuario(usuario);
          }
        },
      ),
    );
  }

  void _showEditarTreinoDialog(Treino treino) {
    final usuarioId = _usuarioSelecionado?.id;
    if (usuarioId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditarTreinoDialog(
        treino: treino,
        onTreinoAtualizado: () {
          _carregarTreinosDoUsuario(usuarioId);
        },
      ),
    );
  }

  void _showDeletarTreinoDialog(Treino treino) {
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
          'Tem certeza que deseja excluir o treino "${treino.nome}"? Esta ação não pode ser desfeita.',
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
              await _deletarTreino(treino);
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

  Future<void> _deletarTreino(Treino treino) async {
    final usuarioId = _usuarioSelecionado?.id;
    if (usuarioId == null) return;

    final response = await _treinoService.deletarTreino(treino.id);

    if (response.success) {
      _carregarTreinosDoUsuario(usuarioId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treino excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao excluir treino'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Treino> get _treinosFiltrados {
    if (_searchQuery.isEmpty) {
      return _treinos;
    }
    return _treinos.where((treino) {
      final nome = treino.nome.toLowerCase();
      final descricao = treino.descricao?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return nome.contains(query) ||
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
        leading: _usuarioSelecionado != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: _voltarParaListaUsuarios,
              )
            : IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          _usuarioSelecionado != null
              ? 'Treinos - ${_usuarioSelecionado?.nome ?? ""}'
              : 'Treinos',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: _usuarioSelecionado != null
          ? FloatingActionButton(
              onPressed: _showCriarTreinoDialog,
              backgroundColor: const Color(0xFFFF312E),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _usuarioSelecionado == null
          ? _buildListaUsuarios()
          : _buildListaTreinos(),
    );
  }

  Widget _buildListaUsuarios() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
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
              hintText: 'Buscar usuários...',
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
          child: _isLoadingUsuarios
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
                            onPressed: _carregarUsuarios,
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
                  : _getUsuariosFiltrados().isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.people_outline,
                                size: 64,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Nenhum usuário encontrado'
                                    : 'Nenhum usuário cadastrado',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _getUsuariosFiltrados().length,
                          itemBuilder: (context, index) {
                            final usuario = _getUsuariosFiltrados()[index];
                            return _buildUsuarioCard(usuario);
                          },
                        ),
        ),
      ],
    );
  }

  List<UsuarioModel> _getUsuariosFiltrados() {
    if (_searchQuery.isEmpty) {
      return _usuarios;
    }
    return _usuarios.where((usuario) {
      final nome = usuario.nome.toLowerCase();
      final email = usuario.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nome.contains(query) || email.contains(query);
    }).toList();
  }

  Widget _buildUsuarioCard(UsuarioModel usuario) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        onTap: () => _selecionarUsuario(usuario),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFFF312E),
                child: Text(
                  usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nome,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario.email,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  _criarTreinoParaUsuario(usuario);
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFFFF312E),
                ),
                tooltip: 'Criar treino',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaTreinos() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
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
              hintText: 'Buscar treinos...',
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
          child: _isLoadingTreinos
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
                            onPressed: () {
                              final usuarioId = _usuarioSelecionado?.id;
                              if (usuarioId != null) {
                                _carregarTreinosDoUsuario(usuarioId);
                              }
                            },
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
                  : _treinosFiltrados.isEmpty
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
                                    ? 'Nenhum treino encontrado'
                                    : 'Nenhum treino cadastrado',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () {
                            final usuarioId = _usuarioSelecionado?.id;
                            if (usuarioId != null) {
                              return _carregarTreinosDoUsuario(usuarioId);
                            }
                            return Future.value();
                          },
                          color: const Color(0xFFFF312E),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _treinosFiltrados.length,
                            itemBuilder: (context, index) {
                              final treino = _treinosFiltrados[index];
                              return _buildTreinoCard(treino);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildTreinoCard(Treino treino) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: const Color(0xFFFF312E),
        collapsedIconColor: colorScheme.onSurface.withOpacity(0.6),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    treino.nome,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (treino.tipoTreino != null &&
                      treino.tipoTreino!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        treino.tipoTreino!,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: colorScheme.onSurface.withOpacity(0.6), size: 20),
              color: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditarTreinoDialog(treino);
                } else if (value == 'delete') {
                  _showDeletarTreinoDialog(treino);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: colorScheme.onSurface, size: 20),
                      const SizedBox(width: 8),
                      Text('Editar',
                          style: TextStyle(color: colorScheme.onSurface)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Excluir', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (treino.descricao != null && treino.descricao!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                treino.descricao!,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (treino.itens.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${treino.itens.length} ${treino.itens.length == 1 ? 'exercício' : 'exercícios'}',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        children: [
          if (treino.descricao != null && treino.descricao!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                treino.descricao!,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ],
          if (treino.itens.isNotEmpty) ...[
            Divider(color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'Exercícios:',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...treino.itens.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF312E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            '${item.ordem}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.exercicioNome ?? 'Exercício',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.series} séries x ${item.repeticoes}',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                            if (item.tempoDescanso != null &&
                                item.tempoDescanso!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Descanso: ${item.tempoDescanso}',
                                  style: TextStyle(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (item.observacao != null &&
                                item.observacao!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  item.observacao!,
                                  style: TextStyle(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.5),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
