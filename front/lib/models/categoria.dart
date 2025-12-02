import 'dart:convert';
import 'plano.dart';

class Categoria {
  final String? id;
  final String nome;

  final List<Plano>? planos;
  final String? dataCriacao;
  final String? dataAtualizacao;

  Categoria({
    this.id,
    required this.nome,

  this.planos,
  this.dataCriacao,
  this.dataAtualizacao,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as String?,
      nome: json['nome'] as String,

      planos: () {
        try {
          final planosData = json['planos'];
          if (planosData is List) {
            return planosData
                .map<Plano?>((p) => (p is Map<String, dynamic>) ? Plano.fromJson(p) : null)
                .whereType<Plano>()
                .toList();
          }
        } catch (_) {}
        return null;
      }(),
      dataCriacao: json['dataCriacao'] as String?,
      dataAtualizacao: json['dataAtualizacao'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nome': nome,
    };

    // Backend CategoriaRequest does not have ID, so we don't send it.
    // if (id != null) map['id'] = id; 

    if (planos != null) {
      map['planos'] = planos!.map((p) => p.toJson()).toList();
    }
    return map;
  }

  @override
  String toString() => jsonEncode(toJson());
}
