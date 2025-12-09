import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlanoResponse {
  final String id;
  final String nome;
  final String descricao;
  final bool ativo;
  final int precoCentavos;

  PlanoResponse({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.ativo,
    required this.precoCentavos,
  });

  factory PlanoResponse.fromJson(Map<String, dynamic> json) {
    return PlanoResponse(
      id: (json['uuid'] ?? json['id']) as String,
      nome: json['nome'],
      descricao: json['descricao'],
      ativo: json['ativo'],
      precoCentavos: json['precoCentavos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'precoCentavos': precoCentavos,
    };
  }

  String get precoFormatado {
    double valorReal = precoCentavos / 100.0;
    return 'R\$ ${valorReal.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class MeuPlanoResponse {
  final String id;
  final String nome;
  final String descricao;
  final bool ativo;
  final int precoCentavos;
  final String? proximoPlanoNome;

  MeuPlanoResponse(
      {required this.id,
      required this.nome,
      required this.descricao,
      required this.ativo,
      required this.precoCentavos,
      required this.proximoPlanoNome});

  factory MeuPlanoResponse.fromJson(Map<String, dynamic> json) {
    return MeuPlanoResponse(
        id: (json['uuid'] ?? json['id']) as String,
        nome: json['nome'],
        descricao: json['descricao'],
        ativo: json['ativo'],
        precoCentavos: json['precoCentavos'],
        proximoPlanoNome: json['proximoPlanoNome']);
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'precoCentavos': precoCentavos,
      'proximoPlanoNome': proximoPlanoNome
    };
  }

  String get precoFormatado {
    double valorReal = precoCentavos / 100.0;
    return 'R\$ ${valorReal.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class CriarPlanoRequest {
  final String nome;
  final String descricao;
  final int precoCentavos;
  final bool ativo;

  CriarPlanoRequest({
    required this.nome,
    required this.descricao,
    required this.precoCentavos,
    this.ativo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
      'precoCentavos': precoCentavos,
      'ativo': ativo,
    };
  }
}

class AtualizarPlanoRequest {
  final String nome;
  final String descricao;

  AtualizarPlanoRequest({
    required this.nome,
    required this.descricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'descricao': descricao,
    };
  }
}

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

class PlanoService {
  static const String baseUrl = 'http://localhost:8080/api/planos';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<List<PlanoResponse>>> listarPlanos(
      {bool ativos = true}) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl?ativos=$ativos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<PlanoResponse> planos =
            data.map((planoJson) => PlanoResponse.fromJson(planoJson)).toList();

        return ApiResponse(success: true, data: planos);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao listar planos',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<PlanoResponse>> buscarPlanoPorId(String id) async {
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
        final PlanoResponse plano = PlanoResponse.fromJson(data);
        return ApiResponse(success: true, data: plano);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao buscar plano',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<PlanoResponse>> criarPlano(
      CriarPlanoRequest request) async {
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
        final PlanoResponse plano = PlanoResponse.fromJson(data);
        return ApiResponse(success: true, data: plano);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao criar plano',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<PlanoResponse>> atualizarPlano(
      String id, AtualizarPlanoRequest request) async {
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
        final PlanoResponse plano = PlanoResponse.fromJson(data);
        return ApiResponse(success: true, data: plano);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao atualizar plano',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<void>> alterarStatusPlano(String id, bool ativo) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/$id/status?ativo=$ativo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao alterar status do plano',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<void>> atualizarPrecoPlano(
      String id, int precoCentavos) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/$id/preco?precoCentavos=$precoCentavos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao atualizar preço do plano',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<MeuPlanoResponse>> obterMeuPlano() async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/meu-plano'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final MeuPlanoResponse plano = MeuPlanoResponse.fromJson(data);
        return ApiResponse(success: true, data: plano);
      } else if (response.statusCode == 204) {
        // No Content
        return ApiResponse(
            success: true, data: null, message: 'Usuário não possui plano');
      } else if (response.statusCode == 403) {
        // Forbidden - user doesn't have permission
        return ApiResponse(
          success: false,
          message: 'Acesso negado. Você não tem permissão para acessar este recurso.',
        );
      } else {
        // Try to parse error message, but handle cases where body might not be JSON
        String errorMessage = 'Erro ao obter plano do usuário';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (e) {
          // If JSON parsing fails, use default message
          errorMessage = 'Erro ao obter plano do usuário (${response.statusCode})';
        }
        return ApiResponse(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<void>> escolherPlano(String planoId) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$planoId/escolher'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao escolher plano',
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
