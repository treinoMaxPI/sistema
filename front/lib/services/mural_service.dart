import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class ComunicadoResponse {
  final String id;
  final String titulo;
  final String mensagem;
  final bool publicado;
  final String dataCriacao;
  final String? imagemUrl;
  final String? autorNome;

  ComunicadoResponse({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.publicado,
    required this.dataCriacao,
    this.imagemUrl,
    this.autorNome,
  });

  factory ComunicadoResponse.fromJson(Map<String, dynamic> json) {
    return ComunicadoResponse(
      id: json['id'],
      titulo: json['titulo'],
      mensagem: json['mensagem'],
      publicado: json['publicado'],
      dataCriacao: json['dataCriacao'],
      imagemUrl: json['imagemUrl'],
      autorNome: json['autorNome'] ?? json['autor'],
    );
  }
}

class CriarComunicadoRequest {
  final String titulo;
  final String mensagem;
  final bool publicado;
  final String? imagemUrl;

  CriarComunicadoRequest({
    required this.titulo,
    required this.mensagem,
    required this.publicado,
    this.imagemUrl,
  });

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'mensagem': mensagem,
        'publicado': publicado,
        if (imagemUrl != null) 'imagemUrl': imagemUrl,
      };
}

class AtualizarComunicadoRequest {
  final String titulo;
  final String mensagem;
  final String? imagemUrl;
  AtualizarComunicadoRequest({required this.titulo, required this.mensagem, this.imagemUrl});
  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'mensagem': mensagem,
        if (imagemUrl != null) 'imagemUrl': imagemUrl,
      };
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  ApiResponse({required this.success, this.message, this.data});
}

class MuralService {
  static const String baseUrl = 'http://localhost:8080/api/mural';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<List<ComunicadoResponse>>> listar({bool all = false}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      }
      final resp = await http.get(
        Uri.parse('$baseUrl?all=$all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        final list = data.map((e) => ComunicadoResponse.fromJson(e)).toList();
        return ApiResponse(success: true, data: list);
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao listar comunicados');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<ComunicadoResponse>> criar(CriarComunicadoRequest req) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      }
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
        return ApiResponse(success: true, data: ComunicadoResponse.fromJson(data));
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao criar comunicado');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<ComunicadoResponse>> atualizar(String id, AtualizarComunicadoRequest req) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      }
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
        return ApiResponse(success: true, data: ComunicadoResponse.fromJson(data));
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao atualizar comunicado');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<void>> alterarStatus(String id, bool publicado) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      }
      final resp = await http.patch(
        Uri.parse('$baseUrl/$id/status?publicado=$publicado'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        return ApiResponse(success: true);
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao alterar status');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<void>> excluir(String id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      }
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
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao excluir comunicado');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<String>> uploadImagem(Uint8List bytes, String filename) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      }
      final uri = Uri.parse('$baseUrl/upload');
      final req = http.MultipartRequest('POST', uri);
      req.headers['Authorization'] = 'Bearer $token';
      // Define content-type apropriado de acordo com a extensão
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
        if (url != null) {
          return ApiResponse(success: true, data: url);
        }
        return ApiResponse(success: false, message: 'Resposta sem URL de imagem');
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao enviar imagem');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<int> getLikesCount(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('likes_count_$id') ?? 0;
  }

  Future<bool> hasLiked(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('liked_$id') ?? false;
  }

  Future<int> toggleLike(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getBool('liked_$id') ?? false;
    int count = prefs.getInt('likes_count_$id') ?? 0;
    if (liked) {
      count = count > 0 ? count - 1 : 0;
      await prefs.setBool('liked_$id', false);
    } else {
      count = count + 1;
      await prefs.setBool('liked_$id', true);
    }
    await prefs.setInt('likes_count_$id', count);
    return count;
  }
}