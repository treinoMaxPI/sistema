import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class AgendamentoResponse {
  final String id;
  final bool recorrente;
  final int? horarioRecorrente;
  final bool? segunda;
  final bool? terca;
  final bool? quarta;
  final bool? quinta;
  final bool? sexta;
  final bool? sabado;
  final bool? domingo;
  final String? dataExata;

  AgendamentoResponse({
    required this.id,
    required this.recorrente,
    this.horarioRecorrente,
    this.segunda,
    this.terca,
    this.quarta,
    this.quinta,
    this.sexta,
    this.sabado,
    this.domingo,
    this.dataExata,
  });

  factory AgendamentoResponse.fromJson(Map<String, dynamic> json) {
    return AgendamentoResponse(
      id: json['id'],
      recorrente: json['recorrente'],
      horarioRecorrente: json['horarioRecorrente'],
      segunda: json['segunda'],
      terca: json['terca'],
      quarta: json['quarta'],
      quinta: json['quinta'],
      sexta: json['sexta'],
      sabado: json['sabado'],
      domingo: json['domingo'],
      dataExata: json['dataExata'],
    );
  }
}

class AulaResponse {
  final String id;
  final String titulo;
  final String descricao;
  final String dataCriacao;
  final String? imagemUrl;
  final Map<String, dynamic>? usuario;
  final Map<String, dynamic>? categoria;
  final AgendamentoResponse? agendamento;
  final int? duracao;

  AulaResponse({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataCriacao,
    this.imagemUrl,
    this.usuario,
    this.categoria,
    this.agendamento,
    this.duracao,
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
      agendamento: json['agendamento'] != null ? AgendamentoResponse.fromJson(json['agendamento']) : null,
      duracao: json['duracao'],
    );
  }
}

class AgendamentoRequest {
  final bool recorrente;
  final int? horarioRecorrente;
  final bool? segunda;
  final bool? terca;
  final bool? quarta;
  final bool? quinta;
  final bool? sexta;
  final bool? sabado;
  final bool? domingo;
  final String? dataExata;

  AgendamentoRequest({
    required this.recorrente,
    this.horarioRecorrente,
    this.segunda,
    this.terca,
    this.quarta,
    this.quinta,
    this.sexta,
    this.sabado,
    this.domingo,
    this.dataExata,
  });

  Map<String, dynamic> toJson() => {
        'recorrente': recorrente,
        if (horarioRecorrente != null) 'horarioRecorrente': horarioRecorrente,
        if (segunda != null) 'segunda': segunda,
        if (terca != null) 'terca': terca,
        if (quarta != null) 'quarta': quarta,
        if (quinta != null) 'quinta': quinta,
        if (sexta != null) 'sexta': sexta,
        if (sabado != null) 'sabado': sabado,
        if (domingo != null) 'domingo': domingo,
        if (dataExata != null) 'dataExata': dataExata,
      };
}

class CriarAulaRequest {
  final String titulo;
  final String descricao;
  final String? bannerUrl;
  final int duracao;
  final String categoriaId;
  final AgendamentoRequest agendamento;

  CriarAulaRequest({
    required this.titulo,
    required this.descricao,
    this.bannerUrl,
    required this.duracao,
    required this.categoriaId,
    required this.agendamento,
  });

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descricao': descricao,
        if (bannerUrl != null) 'bannerUrl': bannerUrl,
        'duracao': duracao,
        'categoriaId': categoriaId,
        'agendamento': agendamento.toJson(),
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

  Future<ApiResponse<List<AulaResponse>>> listarMinhasAulas() async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final resp = await http.get(
        Uri.parse('$baseUrl/minhas'),
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
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao listar suas aulas');
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

  Future<ApiResponse<AulaResponse>> atualizar(String id, CriarAulaRequest req) async {
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
        final url = resp.body;
        if (url.isNotEmpty) return ApiResponse(success: true, data: url);
        return ApiResponse(success: false, message: 'Resposta vazia do servidor');
      }
      final error = json.decode(resp.body);
      return ApiResponse(success: false, message: error['message'] ?? 'Erro ao enviar imagem');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }
}
