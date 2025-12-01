import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'plano_service.dart';

class EntradaSaidaReportItem {
  final String usuarioId;
  final String nome;
  final DateTime data;
  final String? entrada;
  final String? saida;

  EntradaSaidaReportItem({required this.usuarioId, required this.nome, required this.data, this.entrada, this.saida});

  factory EntradaSaidaReportItem.fromJson(Map<String, dynamic> json) {
    return EntradaSaidaReportItem(
      usuarioId: json['usuarioId'] ?? json['id'] ?? '',
      nome: json['nome'] ?? '',
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
      entrada: json['entrada']?.toString(),
      saida: json['saida']?.toString(),
    );
  }
}

class PagamentoResumo {
  final int pagos;
  final int pendentes;
  final int quitados;

  PagamentoResumo({required this.pagos, required this.pendentes, required this.quitados});

  factory PagamentoResumo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

    final pagos = json['pagos'] ?? json['paid'] ?? json['pagosCount'] ?? json['countPagos'];
    final pendentes = json['pendentes'] ?? json['pending'] ?? json['pendentesCount'] ?? json['countPendentes'] ?? json['abertos'];
    final quitados = json['quitados'] ?? json['settled'] ?? json['quitadosCount'] ?? json['countQuitados'];

    return PagamentoResumo(
      pagos: parseInt(pagos),
      pendentes: parseInt(pendentes),
      quitados: parseInt(quitados),
    );
  }
}

class RelatorioService {
  static const String baseEntradas = 'http://localhost:8080/api/admin/relatorios/entradas';
  static const String basePagamentos = 'http://localhost:8080/api/admin/relatorios/pagamentos';
  static const List<String> entradasFallbacks = [
    'http://localhost:8080/api/relatorios/entradas',
    'http://localhost:8080/api/admin/entradas',
  ];
  static const List<String> pagamentosFallbacks = [
    'http://localhost:8080/api/relatorios/pagamentos',
    'http://localhost:8080/api/admin/cobrancas/resumo',
  ];

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<List<EntradaSaidaReportItem>>> listarEntradasSaidas({DateTime? inicio, DateTime? fim}) async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final headers = {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
      final q = _rangeQuery(inicio, fim);
      final bases = [baseEntradas, ...entradasFallbacks];
      final List<String> urls = [];
      for (final b in bases) {
        urls.add('$b$q');
        urls.add(b);
      }
      String? lastErr;
      for (final u in urls) {
        final resp = await http.get(Uri.parse(u), headers: headers);
        if (resp.statusCode == 200) {
          final List<dynamic> data = _safeDecodeList(resp.body);
          final list = data.map((e) => EntradaSaidaReportItem.fromJson(e as Map<String, dynamic>)).toList();
          return ApiResponse(success: true, data: list);
        } else {
          final Map<String, dynamic> err = _safeDecode(resp.body);
          lastErr = _mapFriendlyError(resp.statusCode, err['message']);
          // tenta próximo fallback
          continue;
        }
      }
      return ApiResponse(success: false, message: lastErr ?? 'Servidor indisponível. Tente novamente mais tarde.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  Future<ApiResponse<PagamentoResumo>> obterResumoPagamentos({DateTime? inicio, DateTime? fim}) async {
    try {
      final token = await _getToken();
      if (token == null) return ApiResponse(success: false, message: 'Token de acesso não encontrado');
      final headers = {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
      final q = _rangeQuery(inicio, fim);
      final bases = [basePagamentos, ...pagamentosFallbacks];
      final List<String> urls = [];
      for (final b in bases) {
        urls.add('$b$q');
        urls.add(b);
      }
      String? lastErr;
      for (final u in urls) {
        final resp = await http.get(Uri.parse(u), headers: headers);
        if (resp.statusCode == 200) {
          final Map<String, dynamic> data = _safeDecode(resp.body);
          return ApiResponse(success: true, data: PagamentoResumo.fromJson(data));
        } else {
          final Map<String, dynamic> err = _safeDecode(resp.body);
          lastErr = _mapFriendlyError(resp.statusCode, err['message']);
          continue;
        }
      }
      return ApiResponse(success: false, message: lastErr ?? 'Servidor indisponível. Tente novamente mais tarde.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Erro de conexão: $e');
    }
  }

  String _rangeQuery(DateTime? inicio, DateTime? fim) {
    String q = '';
    if (inicio != null || fim != null) {
      final i = inicio?.toIso8601String();
      final f = fim?.toIso8601String();
      q = '?';
      if (i != null) q += 'inicio=$i';
      if (f != null) q += (q.length > 1 ? '&' : '') + 'fim=$f';
    }
    return q;
  }

  Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
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

  String _mapFriendlyError(int status, String? message) {
    switch (status) {
      case 500:
        return 'Estamos com instabilidade no servidor (erro 500). Tente novamente mais tarde.';
      case 404:
        return 'Relatório não encontrado para o período selecionado.';
      case 401:
      case 403:
        return 'Você não tem permissão para acessar este relatório.';
      default:
        return message ?? 'Ocorreu um erro inesperado ao obter o relatório.';
    }
  }
}
