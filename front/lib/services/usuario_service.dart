import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'mural_service.dart';

class UsuarioResponse {
  final String id;
  final String nome;
  final String email;
  final String login;
  final List<String>? roles;

  UsuarioResponse({required this.id, required this.nome, required this.email, required this.login, this.roles});

  factory UsuarioResponse.fromJson(Map<String, dynamic> json) {
    return UsuarioResponse(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      login: json['login'],
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

class UsuarioService {
  static const String baseUrl = 'http://localhost:8080/api/admin/usuarios';
  static const String fallbackBaseUrl = 'http://localhost:8080/api/usuarios';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<List<UsuarioResponse>>> listarClientes() async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final headers = {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
      final urls = [
        '$baseUrl?role=CUSTOMER',
        '$fallbackBaseUrl?role=CUSTOMER',
        baseUrl,
        fallbackBaseUrl,
      ];
      for (final u in urls) {
        final resp = await http.get(Uri.parse(u), headers: headers);
        if (resp.statusCode == 200) {
          final List<dynamic> data = _safeDecodeList(resp.body);
          var list = data.map((e) => UsuarioResponse.fromJson(e as Map<String, dynamic>)).toList();
          if (!u.contains('role=CUSTOMER')) {
            list = list.where((x) => (x.roles ?? []).contains('CUSTOMER')).toList();
          }
          return ApiResponse(success: true, data: list);
        }
      }
      return ApiResponse(success: false, message: 'Erro ao listar usuários');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<void>> atualizarLogin(String id, String novoLogin) async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      http.Response resp = await http.put(
        Uri.parse('$baseUrl/$id/login'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        body: json.encode({'login': novoLogin}),
      );
      if (resp.statusCode == 200) {
        return ApiResponse(success: true);
      } else {
        // Fallback
        resp = await http.put(
          Uri.parse('$fallbackBaseUrl/$id/login'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token', 'Accept': 'application/json'},
          body: json.encode({'login': novoLogin}),
        );
        if (resp.statusCode == 200) return ApiResponse(success: true);
        final error = _safeDecode(resp.body);
        return ApiResponse(success: false, message: error['message'] ?? 'Erro ao atualizar login');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<void>> resetarSenha(String id) async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      http.Response resp = await http.post(
        Uri.parse('$baseUrl/$id/resetar-senha'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      if (resp.statusCode == 200) {
        return ApiResponse(success: true);
      } else {
        // Fallback
        resp = await http.post(
          Uri.parse('$fallbackBaseUrl/$id/resetar-senha'),
          headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        );
        if (resp.statusCode == 200) return ApiResponse(success: true);
        final error = _safeDecode(resp.body);
        return ApiResponse(success: false, message: error['message'] ?? 'Erro ao resetar senha');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'message': 'Erro inesperado'};
    } catch (_) {
      return {'message': 'Erro inesperado'};
    }
  }

  List<dynamic> _safeDecodeList(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is List) return decoded;
      return [];
    } catch (_) {
      return [];
    }
  }
}