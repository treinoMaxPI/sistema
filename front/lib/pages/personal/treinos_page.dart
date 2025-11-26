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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir o treino "${treino.nome}"? Esta ação não pode ser desfeita.',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
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
      final nivel = treino.nivel?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return nome.contains(query) ||
          descricao.contains(query) ||
          nivel.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: _usuarioSelecionado != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _voltarParaListaUsuarios,
              )
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _usuarioSelecionado != null
              ? 'Treinos - ${_usuarioSelecionado?.nome ?? ""}'
              : 'Treinos',
          style: const TextStyle(
            color: Colors.white,
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
              hintText: 'Buscar usuários...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[800]!),
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
                              style: const TextStyle(
                                color: Colors.white,
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
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                    ? 'Nenhum usuário encontrado'
                                    : 'Nenhum usuário cadastrado',
                                  style: const TextStyle(
                                    color: Colors.white,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
        color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                  usuario.nome.isNotEmpty
                      ? usuario.nome[0].toUpperCase()
                      : 'U',
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
              ),
                                const SizedBox(height: 4),
                                Text(
                      usuario.email,
                                style: const TextStyle(
                        color: Colors.grey,
                                  fontSize: 14,
                      ),
                    ),
                            ],
                          ),
                        ),
              const Icon(
                Icons.chevron_right,
                        color: Colors.grey,
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar treinos...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
    setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
                  enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[800]!),
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
                style: const TextStyle(
                  color: Colors.white,
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
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Nenhum treino encontrado'
                                    : 'Nenhum treino cadastrado',
                                style: const TextStyle(
                                  color: Colors.white,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: const Color(0xFFFF312E),
        collapsedIconColor: Colors.grey,
        title: Row(
          children: [
            Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text(
                    treino.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (treino.tipoTreino != null && treino.tipoTreino!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                    child: Text(
                        treino.tipoTreino!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              color: const Color(0xFF1A1A1A),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditarTreinoDialog(treino);
                } else if (value == 'delete') {
                  _showDeletarTreinoDialog(treino);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Editar', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
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
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (treino.nivel != null && treino.nivel!.isNotEmpty) ...[
              const SizedBox(height: 8),
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF312E).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                            child: Text(
                  treino.nivel!,
                              style: const TextStyle(
                                color: Color(0xFFFF312E),
                    fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
            ],
            if (treino.itens.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                            children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                              Text(
                    '${treino.itens.length} ${treino.itens.length == 1 ? 'exercício' : 'exercícios'}',
                    style: const TextStyle(
                      color: Colors.grey,
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
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                      ),
                    ),
                  ),
                ],
          if (treino.itens.isNotEmpty) ...[
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),
                  const Text(
              'Exercícios:',
                    style: TextStyle(
                      color: Colors.white,
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
                                style: const TextStyle(
                                  color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                              '${item.series} séries x ${item.repeticoes}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            if (item.tempoDescanso != null &&
                                item.tempoDescanso!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Descanso: ${item.tempoDescanso}',
                                  style: const TextStyle(
                                    color: Colors.grey,
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
                                    color: Colors.grey[600],
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

