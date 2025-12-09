class AtivacaoMuscular {
  final String id;
  final String grupoMuscular;
  final int? peso;

  AtivacaoMuscular({
    required this.id,
    required this.grupoMuscular,
    this.peso,
  });

  factory AtivacaoMuscular.fromJson(Map<String, dynamic> json) {
    return AtivacaoMuscular(
      id: json['id'],
      grupoMuscular: json['grupoMuscular'],
      peso: json['peso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grupoMuscular': grupoMuscular,
      'peso': peso,
    };
  }

  String get displayText {
    return grupoMuscular;
  }

  String get displayTextWithScore {
    if (peso != null) {
      return '$grupoMuscular ($peso)';
    }
    return grupoMuscular;
  }
}

class Exercicio {
  final String id;
  final String nome;
  final String? descricao;
  final List<AtivacaoMuscular> ativacaoMuscular;
  final String? videoUrl;

  Exercicio({
    required this.id,
    required this.nome,
    this.descricao,
    required this.ativacaoMuscular,
    this.videoUrl,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    List<AtivacaoMuscular> ativacoes = [];
    if (json['ativacaoMuscular'] != null) {
      final ativacoesList = json['ativacaoMuscular'] as List;
      ativacoes = ativacoesList.map((ativacao) {
        if (ativacao is Map) {
          return AtivacaoMuscular.fromJson(ativacao as Map<String, dynamic>);
        }

        return AtivacaoMuscular(
          id: '',
          grupoMuscular: ativacao.toString(),
          peso: null,
        );
      }).toList();
    }

    return Exercicio(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      ativacaoMuscular: ativacoes,
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'ativacaoMuscular': ativacaoMuscular.map((a) => a.toJson()).toList(),
      'videoUrl': videoUrl,
    };
  }

  String get grupoMuscularDisplay {
    if (ativacaoMuscular.isEmpty) return 'N/A';
    return ativacaoMuscular.map((a) => a.displayText).join(', ');
  }

  String get grupoMuscularDisplayWithScore {
    if (ativacaoMuscular.isEmpty) return 'N/A';
    return ativacaoMuscular.map((a) => a.displayTextWithScore).join(', ');
  }

  List<String> get grupoMuscular {
    return ativacaoMuscular.map((a) => a.grupoMuscular).toList();
  }
}

class CriarExercicioRequest {
  final String nome;
  final String? descricao;
  final List<String> grupoMuscular;
  final String? videoUrl;

  CriarExercicioRequest({
    required this.nome,
    this.descricao,
    required this.grupoMuscular,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'nome': nome,
    };

    if (grupoMuscular.isNotEmpty) {
      json['ativacaoMuscular'] = grupoMuscular
          .map((grupo) => <String, dynamic>{'grupoMuscular': grupo})
          .toList();
    }

    if (descricao != null && descricao!.isNotEmpty) {
      json['descricao'] = descricao;
    }

    if (videoUrl != null && videoUrl!.isNotEmpty) {
      json['videoUrl'] = videoUrl;
    }

    return json;
  }
}

class AtualizarExercicioRequest {
  final String nome;
  final String? descricao;
  final List<String> grupoMuscular;
  final String? videoUrl;

  AtualizarExercicioRequest({
    required this.nome,
    this.descricao,
    required this.grupoMuscular,
    this.videoUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'nome': nome,
    };

    if (grupoMuscular.isNotEmpty) {
      json['ativacaoMuscular'] = grupoMuscular
          .map((grupo) => <String, dynamic>{'grupoMuscular': grupo})
          .toList();
    }

    if (descricao != null && descricao!.isNotEmpty) {
      json['descricao'] = descricao;
    }

    if (videoUrl != null && videoUrl!.isNotEmpty) {
      json['videoUrl'] = videoUrl;
    }

    return json;
  }
}
