import 'dart:convert';

class Plano {
  final String? id;
  final String nome;
  final String descricao;
  final bool ativo;
  final int precoCentavos;

  Plano({
    this.id,
    required this.nome,
    required this.descricao,
    required this.ativo,
    required this.precoCentavos,
  });

  factory Plano.fromJson(Map<String, dynamic> json) {
    return Plano(
      id: json['id'] as String?,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      ativo: json['ativo'] as bool,
      precoCentavos: json['precoCentavos'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'precoCentavos': precoCentavos,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  @override
  String toString() => jsonEncode(toJson());
}
