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
    return ItemTreino(
      id: json['id'],
      exercicioId: json['exercicio'] != null 
          ? (json['exercicio'] is Map ? json['exercicio']['id'] : json['exercicio'].toString())
          : json['exercicioId'] ?? '',
      exercicioNome: json['exercicio'] != null && json['exercicio'] is Map
          ? json['exercicio']['nome']
          : null,
      exercicioVideoUrl: json['exercicio'] != null && json['exercicio'] is Map
          ? json['exercicio']['videoUrl']
          : null,
      ordem: json['ordem'],
      series: json['series'],
      repeticoes: json['repeticoes'],
      tempoDescanso: json['tempoDescanso'],
      observacao: json['observacao'],
    );
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
    List<ItemTreino> itens = [];
    if (json['itens'] != null) {
      itens = (json['itens'] as List)
          .map((item) => ItemTreino.fromJson(item))
          .toList();
    }

    String? usuarioId;
    String? usuarioNome;
    if (json['usuario'] != null) {
      if (json['usuario'] is Map) {
        usuarioId = json['usuario']['id'];
        usuarioNome = json['usuario']['nome'];
      } else {
        usuarioId = json['usuario'].toString();
      }
    } else {
      usuarioId = json['usuarioId'];
    }

    return Treino(
      id: json['id'],
      nome: json['nome'],
      tipoTreino: json['tipoTreino'],
      descricao: json['descricao'],
      nivel: json['nivel'],
      itens: itens,
      usuarioId: usuarioId,
      usuarioNome: usuarioNome,
    );
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

