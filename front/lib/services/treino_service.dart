import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treino.dart';
import 'usuario_service.dart';
import 'offline_service.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });
}

class TreinoService {
  static const String baseUrl = 'http://localhost:8080/api/treino';
  final OfflineService _offlineService = OfflineService();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<List<Treino>>> listarTodos({String? usuarioId}) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        // Se não tem token, verifica se está em modo offline
        final isOffline = await _offlineService.isModoOffline();
        if (isOffline) {
          final treinosCache = await _offlineService.carregarTreinosCache();
          return ApiResponse(success: true, data: treinosCache);
        }
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final url = usuarioId != null 
          ? Uri.parse('$baseUrl?usuarioId=$usuarioId')
          : Uri.parse(baseUrl);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          final List<Treino> treinos = data
              .map((treinoJson) {
                try {
                  return Treino.fromJson(treinoJson as Map<String, dynamic>);
                } catch (e) {
                  print('Erro ao converter treino: $e');
                  print('Treino JSON: $treinoJson');
                  return null;
                }
              })
              .whereType<Treino>()
              .toList();

          // Salva no cache quando conseguir buscar do backend
          await _offlineService.salvarTreinosCache(treinos);
          await _offlineService.setModoOffline(false);

          return ApiResponse(success: true, data: treinos);
        } catch (e) {
          print('Erro ao decodificar resposta: $e');
          print('Response body: ${response.body}');
          return ApiResponse(
            success: false,
            message: 'Erro ao processar resposta: $e',
          );
        }
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao listar treinos',
        );
      }
    } catch (e) {
      // Erro de conexão - verifica se está em modo offline
      final isOffline = await _offlineService.isModoOffline();
      if (isOffline) {
        final treinosCache = await _offlineService.carregarTreinosCache();
        return ApiResponse(
          success: true,
          data: treinosCache,
          message: 'Modo offline - dados do cache',
        );
      }
      
      // Se não está em modo offline, retorna erro de conexão
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<Treino>> buscarPorId(String id) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Treino treino = Treino.fromJson(data);
        return ApiResponse(success: true, data: treino);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao buscar treino',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<Treino>> criarTreino(CriarTreinoRequest request) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final Treino treino = Treino.fromJson(data);
        return ApiResponse(success: true, data: treino);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao criar treino',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<Treino>> atualizarTreino(
      String id, AtualizarTreinoRequest request) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Treino treino = Treino.fromJson(data);
        return ApiResponse(success: true, data: treino);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao atualizar treino',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<void>> deletarTreino(String id) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        return ApiResponse(success: true);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao deletar treino',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<List<UsuarioModel>>> listarUsuariosComTreinos() async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios-com-treinos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<UsuarioModel> usuarios =
            data.map((usuarioJson) => UsuarioModel.fromJson(usuarioJson)).toList();

        return ApiResponse(success: true, data: usuarios);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao listar usuários com treinos',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> iniciarTreino(String treinoId) async {
    try {
      // Verifica se está em modo offline
      final isOffline = await _offlineService.isModoOffline();
      
      if (isOffline) {
        // Busca o treino do cache para obter o nome
        final treinosCache = await _offlineService.carregarTreinosCache();
        final treino = treinosCache.firstWhere(
          (t) => t.id == treinoId,
          orElse: () => Treino(
            id: treinoId,
            nome: 'Treino',
            itens: [],
          ),
        );

        // Salva execução offline
        final execucaoId = await _offlineService.salvarExecucaoIniciadaOffline(
          treinoId,
          treino.nome,
        );

        return ApiResponse(
          success: true,
          data: {
            'id': execucaoId,
            'treino': {
              'id': treinoId,
              'nome': treino.nome,
            },
            'dataInicio': DateTime.now().toIso8601String(),
            'finalizada': false,
          },
        );
      }

      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$treinoId/iniciar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(success: true, data: data);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao iniciar treino',
        );
      }
    } catch (e) {
      // Se for erro de conexão e não estiver em modo offline, tenta usar modo offline
      final isOffline = await _offlineService.isModoOffline();
      if (!isOffline) {
        // Verifica se é erro de conexão
        final backendDisponivel = await _offlineService.verificarBackendDisponivel();
        if (!backendDisponivel) {
          // Backend não disponível, tenta salvar offline
          try {
            final treinosCache = await _offlineService.carregarTreinosCache();
            final treino = treinosCache.firstWhere(
              (t) => t.id == treinoId,
              orElse: () => Treino(
                id: treinoId,
                nome: 'Treino',
                itens: [],
              ),
            );

            final execucaoId = await _offlineService.salvarExecucaoIniciadaOffline(
              treinoId,
              treino.nome,
            );

            return ApiResponse(
              success: true,
              data: {
                'id': execucaoId,
                'treino': {
                  'id': treinoId,
                  'nome': treino.nome,
                },
                'dataInicio': DateTime.now().toIso8601String(),
                'finalizada': false,
              },
            );
          } catch (e2) {
            return ApiResponse(
              success: false,
              message: 'Erro de conexão: $e',
            );
          }
        }
      }
      
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> finalizarTreino(String execucaoId) async {
    try {
      // Verifica se está em modo offline
      final isOffline = await _offlineService.isModoOffline();
      
      if (isOffline) {
        // Finaliza execução offline
        await _offlineService.finalizarExecucaoOffline(execucaoId);
        
        // Busca a execução finalizada
        final execucoesFinalizadasJson = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('execucoes_finalizadas_offline'));
        
        if (execucoesFinalizadasJson != null && execucoesFinalizadasJson.isNotEmpty) {
          final execucoes = json.decode(execucoesFinalizadasJson) as List;
          try {
            final execucao = execucoes.firstWhere(
              (e) => e['id'] == execucaoId,
            ) as Map<String, dynamic>?;
            
            if (execucao != null) {
              return ApiResponse(
                success: true,
                data: execucao,
              );
            }
          } catch (e) {
            // Execução não encontrada, continua com resposta padrão
          }
        }

        return ApiResponse(
          success: true,
          data: {
            'id': execucaoId,
            'finalizada': true,
            'dataFim': DateTime.now().toIso8601String(),
          },
        );
      }

      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/execucao/$execucaoId/finalizar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(success: true, data: data);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao finalizar treino',
        );
      }
    } catch (e) {
      // Se for erro de conexão e não estiver em modo offline, tenta usar modo offline
      final isOffline = await _offlineService.isModoOffline();
      if (!isOffline) {
        // Verifica se é erro de conexão
        final backendDisponivel = await _offlineService.verificarBackendDisponivel();
        if (!backendDisponivel) {
          // Backend não disponível, tenta finalizar offline
          try {
            await _offlineService.finalizarExecucaoOffline(execucaoId);
            return ApiResponse(
              success: true,
              data: {
                'id': execucaoId,
                'finalizada': true,
                'dataFim': DateTime.now().toIso8601String(),
              },
            );
          } catch (e2) {
            return ApiResponse(
              success: false,
              message: 'Erro de conexão: $e',
            );
          }
        }
      }
      
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> listarHistorico() async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/execucao/historico'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.isEmpty || body == '[]' || body == 'null') {
          return ApiResponse(success: true, data: []);
        }
        try {
          final decoded = json.decode(body);
          if (decoded is List) {
            final List<Map<String, dynamic>> historico = decoded
                .whereType<Map>()
                .map((item) => item as Map<String, dynamic>)
                .toList();
            return ApiResponse(success: true, data: historico);
          } else {
            return ApiResponse(success: true, data: []);
          }
        } catch (e) {
          print('Erro ao decodificar histórico: $e');
          return ApiResponse(success: true, data: []);
        }
      } else {
        final errorData = response.body.isNotEmpty 
            ? json.decode(response.body) 
            : <String, dynamic>{};
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao buscar histórico',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>?>> buscarExecucaoAtiva() async {
    try {
      // Verifica se está em modo offline
      final isOffline = await _offlineService.isModoOffline();
      
      if (isOffline) {
        // Busca execução ativa offline
        final execucaoAtiva = await _offlineService.buscarExecucaoAtivaOffline();
        if (execucaoAtiva != null) {
          return ApiResponse(success: true, data: execucaoAtiva);
        }
        return ApiResponse(success: true, data: null);
      }

      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/execucao/ativa'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = response.body.trim();
        // Se o body estiver vazio ou for "null", não há execução ativa
        if (body.isEmpty || body == 'null') {
          return ApiResponse(success: true, data: null);
        }
        final data = json.decode(body);
        return ApiResponse(success: true, data: data);
      } else if (response.statusCode == 404) {
        // Trata 404 como "não há execução ativa" (compatibilidade)
        return ApiResponse(success: true, data: null);
      } else {
        final errorData = response.body.isNotEmpty 
            ? json.decode(response.body) 
            : <String, dynamic>{};
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao buscar execução ativa',
        );
      }
    } catch (e) {
      // Se for erro de conexão, tenta buscar offline
      final isOffline = await _offlineService.isModoOffline();
      if (isOffline) {
        final execucaoAtiva = await _offlineService.buscarExecucaoAtivaOffline();
        if (execucaoAtiva != null) {
          return ApiResponse(success: true, data: execucaoAtiva);
        }
        return ApiResponse(success: true, data: null);
      }
      
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }
}


