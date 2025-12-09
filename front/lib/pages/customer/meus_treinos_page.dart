import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/treino_service.dart';
import '../../models/treino.dart';
import '../../models/execucao_treino.dart';
import 'executar_treino_page.dart';

// Para web - imports condicionais
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html if (dart.library.html) 'dart:html';
// ignore: avoid_web_libraries_in_flutter  
import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';

class MeusTreinosPage extends StatefulWidget {
  const MeusTreinosPage({super.key});

  @override
  State<MeusTreinosPage> createState() => _MeusTreinosPageState();
}

class _MeusTreinosPageState extends State<MeusTreinosPage> {
  final TreinoService _treinoService = TreinoService();
  List<Treino> _treinos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _ultimoTreinoId; // ID do último treino executado (ativo ou não finalizado)
  bool _temTreinoAtivo = false; // Se há um treino em andamento
  Map<String, DateTime?> _ultimaExecucaoPorTreino = {}; // Mapa: treinoId -> última data de execução finalizada
  String? _proximoTreinoId; // ID do próximo treino a ser executado

  @override
  void initState() {
    super.initState();
    _carregarTreinos();
    _carregarUltimoTreino();
    _carregarHistorico();
  }

  Future<void> _carregarTreinos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Para CUSTOMER, o backend já filtra automaticamente pelos treinos do usuário logado
    final response = await _treinoService.listarTodos();
    
    print('Response success: ${response.success}');
    print('Response data: ${response.data}');
    print('Response data type: ${response.data?.runtimeType}');

    if (response.success && response.data != null) {
      final data = response.data;
      if (data != null && data is List<Treino>) {
        // O serviço já retorna List<Treino>, então podemos usar diretamente
        print('Usando List<Treino> diretamente: ${data.length} treinos');
        setState(() {
          _treinos = data;
          _isLoading = false;
        });
      } else if (data != null && data is List) {
        print('Convertendo List<dynamic> para List<Treino>');
        // Fallback: se vier como List<dynamic>, converter
        try {
          final treinos = (data as List).map((item) {
            try {
              if (item is Map) {
                return Treino.fromJson(item as Map<String, dynamic>);
              } else if (item is Treino) {
                return item;
              }
              return null;
            } catch (e) {
              print('Erro ao converter item para Treino: $e');
              print('Item: $item');
              return null;
            }
          }).whereType<Treino>().toList();
          
          print('Treinos convertidos: ${treinos.length}');
          
          setState(() {
            _treinos = treinos;
            _isLoading = false;
          });
        } catch (e) {
          print('Erro ao processar treinos: $e');
          setState(() {
            _treinos = [];
            _isLoading = false;
            _errorMessage = 'Erro ao processar treinos: $e';
          });
        }
      } else {
        print('Data não é uma lista: ${data.runtimeType}');
        setState(() {
          _treinos = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = response.message ?? 'Erro ao carregar treinos';
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarUltimoTreino() async {
    try {
      final response = await _treinoService.buscarExecucaoAtiva();
      
      if (response.success && response.data != null) {
        final execucao = response.data;
        if (execucao != null && execucao is Map && execucao.isNotEmpty) {
          final treinoId = execucao['treino'] != null 
              ? (execucao['treino'] is Map 
                  ? execucao['treino']['id']?.toString()
                  : execucao['treino'].toString())
              : null;
          
          if (treinoId != null && treinoId.isNotEmpty) {
            if (mounted) {
              setState(() {
                _ultimoTreinoId = treinoId;
                _proximoTreinoId = treinoId; // O próximo é o que está ativo
                _temTreinoAtivo = execucao['finalizada'] == false;
              });
            }
          }
        } else {
          // Se não há execução ativa, limpar os estados
          if (mounted) {
            setState(() {
              _ultimoTreinoId = null;
              _proximoTreinoId = null;
              _temTreinoAtivo = false;
            });
          }
        }
      } else {
        // Se não há execução ativa, limpar os estados
        if (mounted) {
          setState(() {
            _ultimoTreinoId = null;
            _proximoTreinoId = null;
            _temTreinoAtivo = false;
          });
        }
      }
    } catch (e) {
      // Ignora erros ao carregar último treino (não é crítico)
      print('Erro ao carregar último treino: $e');
      // Em caso de erro, limpar estados para evitar problemas
      if (mounted) {
        setState(() {
          _ultimoTreinoId = null;
          _proximoTreinoId = null;
          _temTreinoAtivo = false;
        });
      }
    }
  }

  Future<void> _carregarHistorico() async {
    try {
      final response = await _treinoService.listarHistorico();
      
      if (response.success && response.data != null) {
        final historico = response.data;
        if (historico != null && historico is List && historico.isNotEmpty) {
          // Criar mapa de última execução por treino (apenas finalizadas)
          final Map<String, DateTime?> ultimaExecucao = {};
          
          for (var item in historico) {
            if (item is Map && item.isNotEmpty) {
              try {
                final execucao = ExecucaoTreino.fromJson(item);
                // Só considerar execuções finalizadas com treinoId válido
                if (execucao.treinoId.isNotEmpty && 
                    execucao.finalizada && 
                    execucao.dataFim != null) {
                  final treinoId = execucao.treinoId;
                  // Se não tem data ainda ou esta é mais recente, atualizar
                  if (!ultimaExecucao.containsKey(treinoId) || 
                      ultimaExecucao[treinoId] == null ||
                      (execucao.dataFim != null && ultimaExecucao[treinoId] != null &&
                       execucao.dataFim!.isAfter(ultimaExecucao[treinoId]!))) {
                    ultimaExecucao[treinoId] = execucao.dataFim;
                  }
                }
              } catch (e) {
                print('Erro ao processar execução do histórico: $e');
                // Continua processando outras execuções
              }
            }
          }
          
          if (mounted) {
            setState(() {
              _ultimaExecucaoPorTreino = ultimaExecucao;
            });
          }
        } else {
          // Se não há histórico, limpar o mapa
          if (mounted) {
            setState(() {
              _ultimaExecucaoPorTreino = {};
            });
          }
        }
      }
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      // Em caso de erro, não atualizar o estado para evitar crashes
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
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final outline = Theme.of(context).colorScheme.outline;
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meus Treinos',
          style: TextStyle(
            color: onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              style: TextStyle(color: onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar treinos...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2196F3),
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
                      color: Color(0xFF2196F3),
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
                                color: onSurface,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _carregarTreinos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
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
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Nenhum treino encontrado'
                                      : 'Nenhum treino cadastrado',
                                  style: TextStyle(
                                    color: onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Seu personal trainer ainda não criou treinos para você.',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await _carregarTreinos();
                              await _carregarUltimoTreino();
                              await _carregarHistorico();
                            },
                            color: const Color(0xFF2196F3),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _treinosFiltrados.length,
                              itemBuilder: (context, index) {
                                final treino = _treinosFiltrados[index];
                                final isUltimoTreino = _ultimoTreinoId == treino.id;
                                final isProximoTreino = _proximoTreinoId == treino.id;
                                final ultimaExecucao = _ultimaExecucaoPorTreino[treino.id];
                                return _buildTreinoCard(
                                  treino, 
                                  isUltimoTreino: isUltimoTreino,
                                  isProximoTreino: isProximoTreino,
                                  ultimaExecucao: ultimaExecucao,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _iniciarTreino(Treino treino) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2196F3),
        ),
      ),
    );

    final response = await _treinoService.iniciarTreino(treino.id);

    if (mounted) {
      Navigator.pop(context); // Fechar loading

      if (response.success && response.data != null) {
        final data = response.data;
        if (data != null && data is Map && data['id'] != null) {
          final execucaoId = data['id'].toString();
          
          // Navegar para a tela de execução
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExecutarTreinoPage(
                treino: treino,
                execucaoId: execucaoId,
              ),
            ),
          );

          // Se o treino foi finalizado, recarregar a lista e atualizar último treino
          if (resultado == true) {
            _carregarTreinos();
            _carregarUltimoTreino();
            _carregarHistorico();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: dados da execução inválidos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Erro ao iniciar treino'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarVideo(String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => _VideoDialog(videoUrl: videoUrl),
    );
  }

  String _formatarData(DateTime? data) {
    if (data == null) return '';
    
    final agora = DateTime.now();
    final diferenca = agora.difference(data);
    
    if (diferenca.inDays == 0) {
      if (diferenca.inHours == 0) {
        if (diferenca.inMinutes == 0) {
          return 'Há alguns segundos';
        }
        return 'Há ${diferenca.inMinutes} min';
      }
      return 'Há ${diferenca.inHours} h';
    } else if (diferenca.inDays == 1) {
      return 'Ontem';
    } else if (diferenca.inDays < 7) {
      return 'Há ${diferenca.inDays} dias';
    } else if (diferenca.inDays < 30) {
      final semanas = (diferenca.inDays / 7).floor();
      return 'Há $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
    } else {
      final meses = (diferenca.inDays / 30).floor();
      return 'Há $meses ${meses == 1 ? 'mês' : 'meses'}';
    }
  }

  Widget _buildTreinoCard(
    Treino treino, {
    bool isUltimoTreino = false,
    bool isProximoTreino = false,
    DateTime? ultimaExecucao,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUltimoTreino 
            ? BorderSide(
                color: _temTreinoAtivo 
                    ? const Color(0xFFFF312E) 
                    : const Color(0xFF4CAF50),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: const Color(0xFF2196F3),
        collapsedIconColor: Colors.grey,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          treino.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isProximoTreino && !_temTreinoAtivo) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2196F3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.next_plan,
                                size: 14,
                                color: Color(0xFF2196F3),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Próximo',
                                style: TextStyle(
                                  color: Color(0xFF2196F3),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isUltimoTreino) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _temTreinoAtivo 
                                ? const Color(0xFFFF312E).withOpacity(0.2)
                                : const Color(0xFF4CAF50).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _temTreinoAtivo 
                                  ? const Color(0xFFFF312E)
                                  : const Color(0xFF4CAF50),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _temTreinoAtivo ? Icons.play_circle : Icons.check_circle,
                                size: 14,
                                color: _temTreinoAtivo 
                                    ? const Color(0xFFFF312E)
                                    : const Color(0xFF4CAF50),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _temTreinoAtivo ? 'Em andamento' : 'Último treino',
                                style: TextStyle(
                                  color: _temTreinoAtivo 
                                      ? const Color(0xFFFF312E)
                                      : const Color(0xFF4CAF50),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
                  if (ultimaExecucao != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.history,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Última vez: ${_formatarData(ultimaExecucao)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ] else if (!isProximoTreino && !isUltimoTreino) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Nunca executado',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Botão Play
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                onPressed: () => _iniciarTreino(treino),
                tooltip: 'Iniciar treino',
              ),
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
                  color: const Color(0xFF2196F3).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  treino.nivel!,
                  style: const TextStyle(
                    color: Color(0xFF2196F3),
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
                          color: const Color(0xFF2196F3),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.exercicioNome ?? 'Exercício',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (item.exercicioVideoUrl != null &&
                                    item.exercicioVideoUrl!.isNotEmpty)
                                  IconButton(
                                    onPressed: () => _mostrarVideo(item.exercicioVideoUrl!),
                                    icon: const Icon(
                                      Icons.play_circle_outline,
                                      color: Color(0xFF2196F3),
                                      size: 28,
                                    ),
                                    tooltip: 'Ver vídeo do exercício',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                              ],
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

// Dialog para exibir vídeo do exercício
class _VideoDialog extends StatelessWidget {
  final String videoUrl;

  const _VideoDialog({required this.videoUrl});

  bool _isImageOrGif(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.gif') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.webp') ||
        lowerUrl.contains('.gif') ||
        lowerUrl.contains('image/');
  }

  String _getEmbedUrl(String url) {
    // Se for imagem ou GIF, retornar a URL original
    if (_isImageOrGif(url)) {
      return url;
    }
    
    // Se for YouTube
    if (url.contains('youtube.com/watch?v=')) {
      final videoId = url.split('v=')[1].split('&')[0];
      return 'https://www.youtube.com/embed/$videoId';
    }
    // Se for YouTube short link
    if (url.contains('youtu.be/')) {
      final videoId = url.split('youtu.be/')[1].split('?')[0];
      return 'https://www.youtube.com/embed/$videoId';
    }
    // Se for Vimeo
    if (url.contains('vimeo.com/')) {
      final videoId = url.split('vimeo.com/')[1].split('?')[0];
      return 'https://player.vimeo.com/video/$videoId';
    }
    // Se já for uma URL de embed, retornar como está
    if (url.contains('embed') || url.contains('player')) {
      return url;
    }
    // Caso contrário, tentar usar como iframe direto
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final embedUrl = _getEmbedUrl(videoUrl);
    final isImage = _isImageOrGif(videoUrl);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    isImage ? 'Demonstração do Exercício' : 'Vídeo do Exercício',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Video/Image player
            isImage
                ? Container(
                    constraints: const BoxConstraints(
                      maxHeight: 500,
                      maxWidth: double.infinity,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        embedUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 300,
                            color: Colors.black,
                              child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2196F3),
                              ),
                              ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.black,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Erro ao carregar imagem',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildVideoPlayer(embedUrl),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String embedUrl) {
    if (kIsWeb) {
      // Para web, criar iframe HTML
      final String viewType = 'iframe-${embedUrl.hashCode}';
      
      // Registrar o viewType (registrar sempre, pois pode ser reutilizado)
      ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final iframe = html.IFrameElement()
            ..src = embedUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..allowFullscreen = true
            ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
          return iframe;
        },
      );
      
      // Usar HtmlElementView do Flutter (disponível apenas em web)
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(viewType: viewType),
      );
    } else {
      // Para mobile, mostrar botão para abrir em navegador
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_filled,
                size: 64,
                color: Color(0xFFFF312E),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vídeo disponível',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Abrir vídeo em navegador externo
                  // Usar url_launcher package se necessário
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                ),
                child: const Text(
                  'Abrir vídeo',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
