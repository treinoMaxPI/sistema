import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class AulaResponse {
  final String id;
  final String titulo;
  final String descricao;
  final String dataCriacao;
  final String? imagemUrl;
  final Map<String, dynamic>? usuario;
  final Map<String, dynamic>? categoria;

  AulaResponse({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataCriacao,
    this.imagemUrl,
    this.usuario,
    this.categoria,
  });

  factory AulaResponse.fromJson(Map<String, dynamic> json) {
    return AulaResponse(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataCriacao: json['dataCriacao'] ?? json['data_criacao'] ?? '',
      imagemUrl: json['bannerUrl'] ?? json['banner_url'] ?? json['imagemUrl'] ?? json['imgUrl'],
      usuario: json['usuario'] as Map<String, dynamic>?,
      categoria: json['categoria'] as Map<String, dynamic>?,
    );
  }
}

class CriarAulaRequest {
  final String titulo;
  final String descricao;
  final String? imagemUrl;
  final String? categoriaId;
  final String? usuarioId;

  CriarAulaRequest({required this.titulo, required this.descricao, this.imagemUrl, this.categoriaId, this.usuarioId});

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descricao': descricao,
        if (imagemUrl != null) 'bannerUrl': imagemUrl,
        if (categoriaId != null) 'categoriaId': categoriaId,
        if (usuarioId != null) 'usuarioId': usuarioId,
      };
}

class AtualizarAulaRequest {
  final String titulo;
  final String descricao;
  final String? imagemUrl;
  AtualizarAulaRequest({required this.titulo, required this.descricao, this.imagemUrl});
  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descricao': descricao,
        if (imagemUrl != null) 'bannerUrl': imagemUrl,
      };
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  ApiResponse({required this.success, this.message, this.data});
}

class AulaService {
  static const String baseUrl = 'http://localhost:8080/api/aulas';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<List<AulaResponse>>> listar() async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final resp = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        final list = data.map((e) => AulaResponse.fromJson(e)).toList();
        return ApiResponse(success: true, data: list);
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao listar aulas');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<AulaResponse>> criar(CriarAulaRequest req) async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final resp = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(req.toJson()),
      );
      if (resp.statusCode == 201) {
        final data = json.decode(resp.body);
        return ApiResponse(success: true, data: AulaResponse.fromJson(data));
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao criar aula');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<AulaResponse>> atualizar(String id, AtualizarAulaRequest req) async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final resp = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(req.toJson()),
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        return ApiResponse(success: true, data: AulaResponse.fromJson(data));
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao atualizar aula');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<void>> excluir(String id) async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final resp = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 204) {
        return ApiResponse(success: true);
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao excluir aula');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<String>> uploadImagem(Uint8List bytes, String filename) async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final uri = Uri.parse('$baseUrl/upload');
      final req = http.MultipartRequest('POST', uri);
      req.headers['Authorization'] = 'Bearer $token';
      final lower = filename.toLowerCase();
      MediaType ct;
      if (lower.endsWith('.png')) {
        ct = MediaType('image', 'png');
      } else if (lower.endsWith('.gif')) {
        ct = MediaType('image', 'gif');
      } else if (lower.endsWith('.webp')) {
        ct = MediaType('image', 'webp');
      } else {
        ct = MediaType('image', 'jpeg');
      }
      req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename, contentType: ct));
      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final url = data['url'] as String?;
        if (url != null) return ApiResponse(success: true, data: url);
        return ApiResponse(success: false, message: 'Resposta sem URL de imagem');
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao enviar imagem');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }
}
