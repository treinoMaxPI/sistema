import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treino.dart';

class OfflineService {
  static const String _treinosCacheKey = 'treinos_cache';
  static const String _isOfflineModeKey = 'is_offline_mode';
  static const String _lastSyncKey = 'last_sync_treinos';
  static const String _execucoesAtivasKey = 'execucoes_ativas_offline';
  static const String _execucoesFinalizadasKey = 'execucoes_finalizadas_offline';
  static const String _filaSincronizacaoKey = 'fila_sincronizacao';
  static const String baseUrl = 'http://localhost:8080/api';

  /// Verifica se o backend está disponível
  Future<bool> verificarBackendDisponivel() async {
    try {
      // Tenta fazer uma requisição simples ao endpoint de treino
      // Se conseguir conectar (mesmo que retorne erro de auth), o servidor está disponível
      final response = await http
          .get(
            Uri.parse('$baseUrl/treino'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      // Qualquer resposta HTTP (mesmo 401/403/500) indica que o servidor está respondendo
      // Apenas timeouts ou erros de conexão indicam que está offline
      // Status codes < 600 indicam que o servidor respondeu
      return response.statusCode < 600;
    } catch (e) {
      // Timeout ou erro de conexão - servidor não está disponível
      return false;
    }
  }

  /// Salva treinos no cache local
  Future<void> salvarTreinosCache(List<Treino> treinos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final treinosJson = treinos.map((t) => t.toJson()).toList();
      await prefs.setString(_treinosCacheKey, json.encode(treinosJson));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      print('Treinos salvos no cache: ${treinos.length}');
    } catch (e) {
      print('Erro ao salvar treinos no cache: $e');
    }
  }

  /// Carrega treinos do cache local
  Future<List<Treino>> carregarTreinosCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final treinosJsonString = prefs.getString(_treinosCacheKey);
      
      if (treinosJsonString == null || treinosJsonString.isEmpty) {
        return [];
      }

      final List<dynamic> treinosJson = json.decode(treinosJsonString);
      final List<Treino> treinos = treinosJson
          .map((json) => Treino.fromJson(json as Map<String, dynamic>))
          .toList();

      print('Treinos carregados do cache: ${treinos.length}');
      return treinos;
    } catch (e) {
      print('Erro ao carregar treinos do cache: $e');
      return [];
    }
  }

  /// Define se está em modo offline
  Future<void> setModoOffline(bool isOffline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOfflineModeKey, isOffline);
  }

  /// Verifica se está em modo offline
  Future<bool> isModoOffline() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isOfflineModeKey) ?? false;
  }

  /// Limpa o cache de treinos
  Future<void> limparCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_treinosCacheKey);
    await prefs.remove(_lastSyncKey);
  }

  /// Obtém a data da última sincronização
  Future<DateTime?> getUltimaSincronizacao() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString(_lastSyncKey);
    if (lastSyncString == null) return null;
    try {
      return DateTime.parse(lastSyncString);
    } catch (e) {
      return null;
    }
  }

  /// Salva uma execução de treino iniciada offline
  Future<String> salvarExecucaoIniciadaOffline(String treinoId, String treinoNome) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final execucaoId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final execucao = {
        'id': execucaoId,
        'treinoId': treinoId,
        'treinoNome': treinoNome,
        'dataInicio': DateTime.now().toIso8601String(),
        'finalizada': false,
      };

      // Carrega execuções ativas existentes
      final execucoesAtivasJson = prefs.getString(_execucoesAtivasKey);
      List<Map<String, dynamic>> execucoesAtivas = [];
      if (execucoesAtivasJson != null && execucoesAtivasJson.isNotEmpty) {
        execucoesAtivas = List<Map<String, dynamic>>.from(
          json.decode(execucoesAtivasJson).map((e) => e as Map<String, dynamic>)
        );
      }

      // Adiciona nova execução
      execucoesAtivas.add(execucao);

      // Salva de volta
      await prefs.setString(_execucoesAtivasKey, json.encode(execucoesAtivas));

      print('Execução iniciada offline salva: $execucaoId');
      return execucaoId;
    } catch (e) {
      print('Erro ao salvar execução iniciada offline: $e');
      rethrow;
    }
  }

  /// Finaliza uma execução de treino offline
  Future<void> finalizarExecucaoOffline(String execucaoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega execuções ativas
      final execucoesAtivasJson = prefs.getString(_execucoesAtivasKey);
      if (execucoesAtivasJson == null || execucoesAtivasJson.isEmpty) {
        return;
      }

      List<Map<String, dynamic>> execucoesAtivas = List<Map<String, dynamic>>.from(
        json.decode(execucoesAtivasJson).map((e) => e as Map<String, dynamic>)
      );

      // Encontra e remove a execução ativa
      Map<String, dynamic>? execucaoEncontrada;
      execucoesAtivas.removeWhere((exec) {
        if (exec['id'] == execucaoId) {
          execucaoEncontrada = exec;
          return true;
        }
        return false;
      });

      if (execucaoEncontrada != null) {
        // Adiciona data de fim e marca como finalizada
        execucaoEncontrada!['dataFim'] = DateTime.now().toIso8601String();
        execucaoEncontrada!['finalizada'] = true;
        
        // Calcula duração
        final dataInicio = DateTime.parse(execucaoEncontrada!['dataInicio']);
        final dataFim = DateTime.now();
        execucaoEncontrada!['duracaoSegundos'] = dataFim.difference(dataInicio).inSeconds;

        // Salva execuções ativas atualizadas
        await prefs.setString(_execucoesAtivasKey, json.encode(execucoesAtivas));

        // Adiciona à lista de finalizadas
        final execucoesFinalizadasJson = prefs.getString(_execucoesFinalizadasKey);
        List<Map<String, dynamic>> execucoesFinalizadas = [];
        if (execucoesFinalizadasJson != null && execucoesFinalizadasJson.isNotEmpty) {
          execucoesFinalizadas = List<Map<String, dynamic>>.from(
            json.decode(execucoesFinalizadasJson).map((e) => e as Map<String, dynamic>)
          );
        }

        execucoesFinalizadas.add(execucaoEncontrada!);
        await prefs.setString(_execucoesFinalizadasKey, json.encode(execucoesFinalizadas));

        // Adiciona à fila de sincronização
        await _adicionarFilaSincronizacao('finalizar', execucaoId, execucaoEncontrada!);

        print('Execução finalizada offline: $execucaoId');
      }
    } catch (e) {
      print('Erro ao finalizar execução offline: $e');
      rethrow;
    }
  }

  /// Busca execução ativa offline
  Future<Map<String, dynamic>?> buscarExecucaoAtivaOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final execucoesAtivasJson = prefs.getString(_execucoesAtivasKey);
      
      if (execucoesAtivasJson == null || execucoesAtivasJson.isEmpty) {
        return null;
      }

      final List<dynamic> execucoesAtivas = json.decode(execucoesAtivasJson);
      if (execucoesAtivas.isEmpty) {
        return null;
      }

      // Retorna a mais recente (última da lista)
      return execucoesAtivas.last as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao buscar execução ativa offline: $e');
      return null;
    }
  }

  /// Adiciona à fila de sincronização
  Future<void> _adicionarFilaSincronizacao(String acao, String execucaoId, Map<String, dynamic> dados) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filaJson = prefs.getString(_filaSincronizacaoKey);
      
      List<Map<String, dynamic>> fila = [];
      if (filaJson != null && filaJson.isNotEmpty) {
        fila = List<Map<String, dynamic>>.from(
          json.decode(filaJson).map((e) => e as Map<String, dynamic>)
        );
      }

      fila.add({
        'acao': acao,
        'execucaoId': execucaoId,
        'dados': dados,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_filaSincronizacaoKey, json.encode(fila));
    } catch (e) {
      print('Erro ao adicionar à fila de sincronização: $e');
    }
  }

  /// Limpa execuções offline
  Future<void> limparExecucoesOffline() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_execucoesAtivasKey);
    await prefs.remove(_execucoesFinalizadasKey);
    await prefs.remove(_filaSincronizacaoKey);
  }
}

