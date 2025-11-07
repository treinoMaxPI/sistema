import 'package:intl/intl.dart';

class PlanoCobrancaCustomerResponse {
  final String id;
  final String planoNome;
  final String mesReferencia;
  final int valorCentavos;
  final bool pago;
  final String dataVencimento;
  final String? dataPagamento;
  final String? observacoes;
  final String dataCriacao;
  final String dataAtualizacao;

  PlanoCobrancaCustomerResponse({
    required this.id,
    required this.planoNome,
    required this.mesReferencia,
    required this.valorCentavos,
    required this.pago,
    required this.dataVencimento,
    this.dataPagamento,
    this.observacoes,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  factory PlanoCobrancaCustomerResponse.fromJson(Map<String, dynamic> json) {
    return PlanoCobrancaCustomerResponse(
      id: json['id'],
      planoNome: json['planoNome'],
      mesReferencia: json['mesReferencia'],
      valorCentavos: json['valorCentavos'],
      pago: json['pago'],
      dataVencimento: json['dataVencimento'],
      dataPagamento: json['dataPagamento'],
      observacoes: json['observacoes'],
      dataCriacao: json['dataCriacao'],
      dataAtualizacao: json['dataAtualizacao'],
    );
  }

  String get valorFormatado {
    double valorReal = valorCentavos / 100.0;
    return 'R\$ ${valorReal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get dataVencimentoFormatada {
    final date = DateTime.parse(dataVencimento);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String get dataPagamentoFormatada {
    if (dataPagamento == null) return 'N/A';
    final date = DateTime.parse(dataPagamento!);
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
