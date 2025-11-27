class ItemTreino {
  final String? id;
  final String exercicioId;
  final String? exercicioNome;
  final String? exercicioVideoUrl;
  final int ordem;
  final int series;
  final String repeticoes;
  final String? tempoDescanso;
  final String? observacao;

  ItemTreino({
    this.id,
    required this.exercicioId,
    this.exercicioNome,
    this.exercicioVideoUrl,
    required this.ordem,
    required this.series,
    required this.repeticoes,
    this.tempoDescanso,
    this.observacao,
  });

  factory ItemTreino.fromJson(Map<String, dynamic> json) {
    try {
      // Extrair exercicioId
      String exercicioId = '';
      if (json['exercicio'] != null) {
        if (json['exercicio'] is Map) {
          exercicioId = json['exercicio']['id']?.toString() ?? '';
        } else {
          exercicioId = json['exercicio'].toString();
        }
      } else if (json['exercicioId'] != null) {
        exercicioId = json['exercicioId'].toString();
      }
      
      if (exercicioId.isEmpty) {
        throw Exception('exercicioId não pode ser vazio');
      }
      
      return ItemTreino(
        id: json['id']?.toString(),
        exercicioId: exercicioId,
        exercicioNome: json['exercicio'] != null && json['exercicio'] is Map
            ? json['exercicio']['nome']?.toString()
            : null,
        exercicioVideoUrl: json['exercicio'] != null && json['exercicio'] is Map
            ? json['exercicio']['videoUrl']?.toString()
            : null,
        ordem: json['ordem'] is int ? json['ordem'] : int.tryParse(json['ordem'].toString()) ?? 0,
        series: json['series'] is int ? json['series'] : int.tryParse(json['series'].toString()) ?? 0,
        repeticoes: json['repeticoes']?.toString() ?? '',
        tempoDescanso: json['tempoDescanso']?.toString(),
        observacao: json['observacao']?.toString(),
      );
    } catch (e) {
      print('Erro ao criar ItemTreino: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'exercicio': {'id': exercicioId},
      'ordem': ordem,
      'series': series,
      'repeticoes': repeticoes,
      if (tempoDescanso != null && tempoDescanso!.isNotEmpty) 'tempoDescanso': tempoDescanso,
      if (observacao != null && observacao!.isNotEmpty) 'observacao': observacao,
    };
  }
}

class Treino {
  final String id;
  final String nome;
  final String? tipoTreino; // Ex: "A", "B", "C", "Empurrar", "Puxar", "Leg Day"
  final String? descricao;
  final String? nivel;
  final List<ItemTreino> itens;
  final String? usuarioId;
  final String? usuarioNome; // Nome do usuário para exibição

  Treino({
    required this.id,
    required this.nome,
    this.tipoTreino,
    this.descricao,
    this.nivel,
    required this.itens,
    this.usuarioId,
    this.usuarioNome,
  });

  factory Treino.fromJson(Map<String, dynamic> json) {
    try {
      List<ItemTreino> itens = [];
      if (json['itens'] != null && json['itens'] is List) {
        itens = (json['itens'] as List)
            .map((item) {
              try {
                if (item is Map) {
                  return ItemTreino.fromJson(item as Map<String, dynamic>);
                }
                return null;
              } catch (e) {
                print('Erro ao converter item do treino: $e');
                return null;
              }
            })
            .whereType<ItemTreino>()
            .toList();
      }

      String? usuarioId;
      String? usuarioNome;
      if (json['usuario'] != null) {
        if (json['usuario'] is Map) {
          usuarioId = json['usuario']['id']?.toString();
          usuarioNome = json['usuario']['nome']?.toString();
        } else {
          usuarioId = json['usuario'].toString();
        }
      } else {
        usuarioId = json['usuarioId']?.toString();
      }

      return Treino(
        id: json['id']?.toString() ?? '',
        nome: json['nome']?.toString() ?? '',
        tipoTreino: json['tipoTreino']?.toString(),
        descricao: json['descricao']?.toString(),
        nivel: json['nivel']?.toString(),
        itens: itens,
        usuarioId: usuarioId,
        usuarioNome: usuarioNome,
      );
    } catch (e) {
      print('Erro ao criar Treino: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      if (descricao != null && descricao!.isNotEmpty) 'descricao': descricao,
      if (nivel != null && nivel!.isNotEmpty) 'nivel': nivel,
      'itens': itens.map((item) => item.toJson()).toList(),
    };
  }
}

class CriarTreinoRequest {
  final String nome;
  final String? tipoTreino;
  final String? descricao;
  final String? nivel;
  final List<ItemTreino> itens;
  final String usuarioId; // Obrigatório para Personal criar treino para aluno

  CriarTreinoRequest({
    required this.nome,
    this.tipoTreino,
    this.descricao,
    this.nivel,
    required this.itens,
    required this.usuarioId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      if (tipoTreino != null && tipoTreino!.isNotEmpty) 'tipoTreino': tipoTreino,
      if (descricao != null && descricao!.isNotEmpty) 'descricao': descricao,
      if (nivel != null && nivel!.isNotEmpty) 'nivel': nivel,
      'itens': itens.map((item) => item.toJson()).toList(),
      'usuarioId': usuarioId,
    };
  }
}

class AtualizarTreinoRequest {
  final String nome;
  final String? tipoTreino;
  final String? descricao;
  final String? nivel;
  final List<ItemTreino> itens;

  AtualizarTreinoRequest({
    required this.nome,
    this.tipoTreino,
    this.descricao,
    this.nivel,
    required this.itens,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      if (tipoTreino != null && tipoTreino!.isNotEmpty) 'tipoTreino': tipoTreino,
      if (descricao != null && descricao!.isNotEmpty) 'descricao': descricao,
      if (nivel != null && nivel!.isNotEmpty) 'nivel': nivel,
      'itens': itens.map((item) => item.toJson()).toList(),
    };
  }
}

