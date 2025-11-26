import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class UsuarioModel {
  final String id;
  final String nome;
  final String email;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
    );
  }
}

class UsuarioService {
  static const String baseUrl = 'http://localhost:8080/api/usuarios';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<List<UsuarioModel>>> listarTodos() async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.get(
        Uri.parse(baseUrl),
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
          message: errorData['message'] ?? 'Erro ao listar usuários',
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

