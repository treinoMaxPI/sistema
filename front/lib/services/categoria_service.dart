import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria.dart';

class CategoriaService {
  final String baseUrl;

  CategoriaService({required this.baseUrl});

  Map<String, String> _headers([String? token]) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String _extractErrorMessage(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body.containsKey('message')) {
        return body['message'] as String;
      }
    } catch (_) {
      // If JSON parsing fails, return a generic message
    }
    return 'Erro ao processar requisição';
  }

  Future<List<Categoria>> listarTodas([String? token]) async {
    final uri = Uri.parse('$baseUrl/api/categorias');
    final res = await http.get(uri, headers: _headers(token));

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data.map((e) => Categoria.fromJson(e as Map<String, dynamic>)).toList();
    }

    throw Exception(_extractErrorMessage(res));
  }

  Future<Categoria> buscarPorId(String id, [String? token]) async {
    final uri = Uri.parse('$baseUrl/api/categorias/$id');
    final res = await http.get(uri, headers: _headers(token));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Categoria.fromJson(data);
    }

    throw Exception(_extractErrorMessage(res));
  }

  Future<Categoria> criar(Categoria categoria, String token) async {
    final uri = Uri.parse('$baseUrl/api/categorias');
    final res = await http.post(uri, headers: _headers(token), body: jsonEncode(categoria.toJson()));

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Categoria.fromJson(data);
    }

    throw Exception(_extractErrorMessage(res));
  }

  Future<Categoria> atualizar(String id, Categoria categoria, String token) async {
    final uri = Uri.parse('$baseUrl/api/categorias/$id');
    final res = await http.put(uri, headers: _headers(token), body: jsonEncode(categoria.toJson()));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Categoria.fromJson(data);
    }

    throw Exception(_extractErrorMessage(res));
  }

  Future<void> deletar(String id, String token) async {
    final uri = Uri.parse('$baseUrl/api/categorias/$id');
    final res = await http.delete(uri, headers: _headers(token));

    if (res.statusCode == 204 || res.statusCode == 200) {
      return;
    }

    throw Exception(_extractErrorMessage(res));
  }
}
