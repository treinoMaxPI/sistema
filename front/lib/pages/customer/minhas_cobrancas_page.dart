import 'package:flutter/material.dart';
import 'package:gym_management/models/plano_cobranca_customer_response.dart';
import 'package:gym_management/services/plano_cobranca_service.dart';
import 'package:gym_management/widgets/page_header.dart';
import 'package:gym_management/theme/typography.dart';

class MinhasCobrancasPage extends StatefulWidget {
  const MinhasCobrancasPage({super.key});

  @override
  State<MinhasCobrancasPage> createState() => _MinhasCobrancasPageState();
}

class _MinhasCobrancasPageState extends State<MinhasCobrancasPage> {
  final PlanoCobrancaService _planoCobrancaService = PlanoCobrancaService();
  List<PlanoCobrancaCustomerResponse> _cobrancas = [];
  bool _isLoading = false;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _fetchCobrancas(0); // Fetch the first page on init
  }

  Future<void> _fetchCobrancas(int page) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (page == 0) {
        // Clear list only if fetching the first page
        _cobrancas = [];
      }
    });

    setState(() {
      _isLoading = true;
    });

    final response = await _planoCobrancaService.getCustomerCobrancas(
      page: page,
      size: 10,
      sortBy: 'dataVencimento',
      sortDir: 'desc',
    );

    if (response.success && response.data != null) {
      setState(() {
        _cobrancas = response.data!.content;
        _currentPage = response.data!.number;
        _totalPages = response.data!.totalPages;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response.message ?? 'Erro ao carregar cobranças')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color to black
      appBar: const PageHeader(title: 'Minhas Cobranças'),
      body: _cobrancas.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cobrancas.isEmpty && !_isLoading
              ? const Center(child: Text('Nenhuma cobrança encontrada.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cobrancas.length,
                        itemBuilder: (context, index) {
                          final cobranca = _cobrancas[index];
                          return Card(
                            color: Colors.grey[900],
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.grey[800]!, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Plano: ${cobranca.planoNome}',
                                      style: AppTypography.titleSmall),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Mês Referência: ${cobranca.mesReferencia}',
                                      style: AppTypography.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text('Valor: ${cobranca.valorFormatado}',
                                      style: AppTypography.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Vencimento: ${cobranca.dataVencimentoFormatada}',
                                      style: AppTypography.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Status: ${cobranca.pago ? 'Pago' : 'Pendente'}',
                                      style: AppTypography.bodyMedium.copyWith(
                                          color: cobranca.pago
                                              ? Colors.green
                                              : const Color(0xFFFF312E))),
                                  if (cobranca.pago) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                        'Data Pagamento: ${cobranca.dataPagamentoFormatada}',
                                        style: AppTypography.bodySmall),
                                  ],
                                  if (cobranca.observacoes != null &&
                                      cobranca.observacoes!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('Observações: ${cobranca.observacoes}',
                                        style: AppTypography.bodySmall),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    _buildPaginationControls(),
                  ],
                ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: _currentPage > 0 && !_isLoading
                    ? const Color(0xFFFF312E)
                    : Colors.grey),
            onPressed: _currentPage > 0 && !_isLoading
                ? () => _fetchCobrancas(_currentPage - 1)
                : null,
          ),
          Text('Página ${_currentPage + 1} de $_totalPages',
              style: AppTypography.bodyMedium),
          IconButton(
            icon: Icon(Icons.arrow_forward,
                color: _currentPage < _totalPages - 1 && !_isLoading
                    ? const Color(0xFFFF312E)
                    : Colors.grey),
            onPressed: _currentPage < _totalPages - 1 && !_isLoading
                ? () => _fetchCobrancas(_currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
