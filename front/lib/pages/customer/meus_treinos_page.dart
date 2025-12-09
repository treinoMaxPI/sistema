import 'package:flutter/material.dart';
// Removido: import 'dart:html' as html if (dart.library.html) 'dart:html';
// Removido: import 'dart:ui_web' as ui_web if (dart.library.html) 'dart:ui_web';
import 'package:url_launcher/url_launcher.dart'; // Import para abrir URLs
import '../../services/treino_service.dart';
import '../../services/offline_service.dart';
import '../../models/treino.dart';
import '../../models/execucao_treino.dart';
import '../../widgets/offline_dialog.dart';
import 'executar_treino_page.dart';

class MeusTreinosPage extends StatefulWidget {
  const MeusTreinosPage({super.key});

  @override
  State<MeusTreinosPage> createState() => _MeusTreinosPageState();
}

class _MeusTreinosPageState extends State<MeusTreinosPage> {
  final TreinoService _treinoService = TreinoService();
  final OfflineService _offlineService = OfflineService();
  List<Treino> _treinos = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String? _ultimoTreinoId; // ID do último treino executado (ativo ou não finalizado)
  bool _temTreinoAtivo = false; // Se há um treino em andamento
  Map<String, DateTime?> _ultimaExecucaoPorTreino = {}; // Mapa: treinoId -> última data de execução finalizada
  String? _proximoTreinoId; // ID do próximo treino a ser executado
  bool _isOfflineMode = false;
  bool _verificandoBackend = false;

  @override
  void initState() {
    super.initState();
    _verificarBackendECarregar();
    _iniciarVerificacaoPeriodica();
  }

  void _iniciarVerificacaoPeriodica() {
    // Verifica a cada 30 segundos se o backend voltou
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isOfflineMode) {
        _verificarSeBackendVoltou();
        _iniciarVerificacaoPeriodica(); // Continua verificando
      }
    });
  }

  Future<void> _verificarSeBackendVoltou() async {
    if (!_isOfflineMode) return;
    
    final backendDisponivel = await _offlineService.verificarBackendDisponivel();
    if (backendDisponivel && mounted) {
      await _offlineService.setModoOffline(false);
      setState(() {
        _isOfflineMode = false;
      });
      
      // Recarrega os dados
      _carregarTreinos();
      _carregarUltimoTreino();
      _carregarHistorico();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conectado ao servidor'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _verificarBackendECarregar() async {
    // Verifica se já está em modo offline
    final isOffline = await _offlineService.isModoOffline();
    if (isOffline) {
      setState(() {
        _isOfflineMode = true;
      });
      _carregarTreinos();
      return;
    }

    // Tenta verificar se o backend está disponível
    setState(() {
      _verificandoBackend = true;
    });

    final backendDisponivel = await _offlineService.verificarBackendDisponivel();
    
    setState(() {
      _verificandoBackend = false;
    });

    if (!backendDisponivel && mounted) {
      // Backend não disponível - mostra dialog
      final continuarOffline = await OfflineDialog.show(
        context,
        onContinuarOffline: () {
          Navigator.of(context).pop(true);
        },
        onTentarNovamente: () async {
          setState(() {
            _verificandoBackend = true;
          });
          
          final disponivel = await _offlineService.verificarBackendDisponivel();
          
          setState(() {
            _verificandoBackend = false;
          });

          if (disponivel) {
            Navigator.of(context).pop(false);
            await _offlineService.setModoOffline(false);
            setState(() {
              _isOfflineMode = false;
            });
            _carregarTreinos();
          } else {
            // Ainda não disponível, mas não fecha o dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Backend ainda não está disponível'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        isLoading: _verificandoBackend,
      );

      if (continuarOffline == true) {
        // Usuário escolheu continuar offline
        await _offlineService.setModoOffline(true);
        setState(() {
          _isOfflineMode = true;
        });
        _carregarTreinos();
      } else {
        // Usuário cancelou ou backend ficou disponível
        if (backendDisponivel) {
          _carregarTreinos();
        }
      }
    } else {
      // Backend disponível
      await _offlineService.setModoOffline(false);
      setState(() {
        _isOfflineMode = false;
      });
      _carregarTreinos();
      _carregarUltimoTreino();
      _carregarHistorico();
    }
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
    print('Is offline mode: $_isOfflineMode');

    if (response.success && response.data != null) {
      // Se a requisição foi bem-sucedida, desativa modo offline
      if (_isOfflineMode) {
        await _offlineService.setModoOffline(false);
        setState(() {
          _isOfflineMode = false;
        });
      }
      
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
      final query = _searchQuery.toLowerCase();
      return nome.contains(query) ||
          descricao.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'Meus Treinos',
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isOfflineMode) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.wifi_off,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 4),
              const Text(
                'Offline',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_isOfflineMode)
            IconButton(
              icon: Icon(Icons.refresh, color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () async {
                // Tenta reconectar
                setState(() {
                  _verificandoBackend = true;
                });
                
                final backendDisponivel = await _offlineService.verificarBackendDisponivel();
                
                setState(() {
                  _verificandoBackend = false;
                });

                if (backendDisponivel) {
                  await _offlineService.setModoOffline(false);
                  setState(() {
                    _isOfflineMode = false;
                  });
                  _carregarTreinos();
                  _carregarUltimoTreino();
                  _carregarHistorico();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conectado ao servidor'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Backend ainda não está disponível'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
            ),
        ],
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar treinos...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _carregarTreinos,
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
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Nenhum treino encontrado'
                                      : 'Nenhum treino cadastrado',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Seu personal trainer ainda não criou treinos para você.',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                              if (_isOfflineMode) {
                                // Tenta reconectar quando em modo offline
                                final backendDisponivel = await _offlineService.verificarBackendDisponivel();
                                if (backendDisponivel) {
                                  await _offlineService.setModoOffline(false);
                                  setState(() {
                                    _isOfflineMode = false;
                                  });
                                  await _carregarTreinos();
                                  await _carregarUltimoTreino();
                                  await _carregarHistorico();
                                } else {
                                  // Ainda offline, apenas recarrega do cache
                                  await _carregarTreinos();
                                }
                              } else {
                                // Modo online normal
                                await _carregarTreinos();
                                await _carregarUltimoTreino();
                                await _carregarHistorico();
                              }
                            },
                            color: const Color(0xFFFF312E),
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
          color: Color(0xFFFF312E),
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

  Future<void> _mostrarVideo(String videoUrl) async {
    final uri = Uri.parse(videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir o vídeo: $videoUrl'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUltimoTreino
            ? BorderSide(
                color: _temTreinoAtivo
                    ? const Color(0xFFFF312E)
                    : const Color(0xFF4CAF50),
                width: 2,
              )
            : BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: const Color(0xFFFF312E),
        collapsedIconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.next_plan,
                                size: 14,
                                color: Color(0xFF2196F3),
                              ),
                              SizedBox(width: 4),
                              Text(
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
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (ultimaExecucao != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Última vez: ${_formatarData(ultimaExecucao)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ] else if (!isProximoTreino && !isUltimoTreino) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Nunca executado',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                color: const Color(0xFFFF312E),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${treino.itens.length} ${treino.itens.length == 1 ? 'exercício' : 'exercícios'}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ],
          if (treino.itens.isNotEmpty) ...[
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'Exercícios:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.exercicioNome ?? 'Exercício',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
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
                                      color: Color(0xFFFF312E),
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
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                                    color: Color(0xFF4CAF50),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
          ],
        ],
      ),
    );
  }
}

// REMOVIDO a classe _VideoDialog original porque usava dart:html/dart:ui_web
// e a funcionalidade foi substituída por url_launcher.
