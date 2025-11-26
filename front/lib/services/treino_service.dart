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
        final List<dynamic> data = json.decode(response.body);
        final List<Treino> treinos =
            data.map((treinoJson) => Treino.fromJson(treinoJson)).toList();

        return ApiResponse(success: true, data: treinos);
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
}


