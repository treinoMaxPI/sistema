class Exercicio {
  final String id;
  final String nome;
  final String? descricao;
  final List<String> grupoMuscular; // Lista de grupos musculares
  final String? videoUrl;

  Exercicio({
    required this.id,
    required this.nome,
    this.descricao,
    required this.grupoMuscular,
    this.videoUrl,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    // Se vier como lista de objetos AtivacaoMuscular
    List<String> grupos = [];
    if (json['ativacaoMuscular'] != null) {
      final ativacoes = json['ativacaoMuscular'] as List;
      grupos = ativacoes.map((ativacao) {
        if (ativacao is Map && ativacao['grupoMuscular'] != null) {
          return ativacao['grupoMuscular'].toString();
        }
        return ativacao.toString();
      }).toList();
    } else if (json['grupoMuscular'] != null) {
      // Se vier como lista direta
      if (json['grupoMuscular'] is List) {
        grupos = (json['grupoMuscular'] as List).map((e) => e.toString()).toList();
      } else {
        // Se vier como string única (compatibilidade)
        grupos = [json['grupoMuscular'].toString()];
      }
    }
    
    return Exercicio(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      grupoMuscular: grupos,
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'grupoMuscular': grupoMuscular,
      'videoUrl': videoUrl,
    };
  }
  
  // Helper para exibir grupos musculares
  String get grupoMuscularDisplay {
    if (grupoMuscular.isEmpty) return 'N/A';
    return grupoMuscular.join(', ');
  }
}

class CriarExercicioRequest {
  final String nome;
  final String? descricao;
  final List<String> grupoMuscular; // Lista de grupos musculares
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
    
    // Enviar como lista de objetos AtivacaoMuscular
    if (grupoMuscular.isNotEmpty) {
      json['ativacaoMuscular'] = grupoMuscular.map((grupo) => 
        <String, dynamic>{'grupoMuscular': grupo}
      ).toList();
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
  final List<String> grupoMuscular; // Lista de grupos musculares
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
    
    // Enviar como lista de objetos AtivacaoMuscular
    if (grupoMuscular.isNotEmpty) {
      json['ativacaoMuscular'] = grupoMuscular.map((grupo) => 
        <String, dynamic>{'grupoMuscular': grupo}
      ).toList();
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

