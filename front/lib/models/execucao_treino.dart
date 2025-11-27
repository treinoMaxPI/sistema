class ExecucaoTreino {
  final String id;
  final String treinoId;
  final String? treinoNome;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool finalizada;
  final int? duracaoSegundos;

  ExecucaoTreino({
    required this.id,
    required this.treinoId,
    this.treinoNome,
    required this.dataInicio,
    this.dataFim,
    required this.finalizada,
    this.duracaoSegundos,
  });

  factory ExecucaoTreino.fromJson(Map<String, dynamic> json) {
    try {
      String treinoId = '';
      String? treinoNome;
      
      if (json['treino'] != null) {
        if (json['treino'] is Map) {
          treinoId = json['treino']['id']?.toString() ?? '';
          treinoNome = json['treino']['nome']?.toString();
        } else {
          treinoId = json['treino'].toString();
        }
      }

      DateTime dataInicio;
      try {
        dataInicio = json['dataInicio'] != null
            ? DateTime.parse(json['dataInicio'].toString())
            : DateTime.now();
      } catch (e) {
        dataInicio = DateTime.now();
      }

      DateTime? dataFim;
      if (json['dataFim'] != null) {
        try {
          dataFim = DateTime.parse(json['dataFim'].toString());
        } catch (e) {
          dataFim = null;
        }
      }

      return ExecucaoTreino(
        id: json['id']?.toString() ?? '',
        treinoId: treinoId,
        treinoNome: treinoNome,
        dataInicio: dataInicio,
        dataFim: dataFim,
        finalizada: json['finalizada'] == true,
        duracaoSegundos: json['duracaoSegundos'] is int 
            ? json['duracaoSegundos'] 
            : (json['duracaoSegundos'] != null 
                ? int.tryParse(json['duracaoSegundos'].toString()) 
                : null),
      );
    } catch (e) {
      print('Erro ao criar ExecucaoTreino: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

