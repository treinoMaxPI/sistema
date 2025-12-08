import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treino.dart';
import 'usuario_service.dart';

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

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<List<Treino>>> listarTodos({String? usuarioId}) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
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
      );

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
      );

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
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> finalizarTreino(String execucaoId) async {
    try {
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
      );

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
      );

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
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<List<String>>> gerarTreino(List<String> tiposTreino) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/gerar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'tiposTreino': tiposTreino}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> exercicioIds = data.cast<String>();
        return ApiResponse(success: true, data: exercicioIds);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao gerar treino',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }
}


