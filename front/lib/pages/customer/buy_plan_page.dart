import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management/widgets/page_header.dart';
import '../../services/plano_service.dart';
import '../../theme/typography.dart';

class BuyPlanPage extends ConsumerStatefulWidget {
  const BuyPlanPage({super.key});

  @override
  ConsumerState<BuyPlanPage> createState() => _BuyPlanPageState();
}

class _BuyPlanPageState extends ConsumerState<BuyPlanPage> {
  late Future<ApiResponse<List<PlanoResponse>>> _planosFuture;

  @override
  void initState() {
    super.initState();
    _planosFuture = PlanoService().listarPlanos(ativos: true);
  }

  Future<void> _refreshPlanos() async {
    setState(() {
      _planosFuture = PlanoService().listarPlanos(ativos: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const PageHeader(title: 'Comprar Plano'),
      body: FutureBuilder<ApiResponse<List<PlanoResponse>>>(
        future: _planosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar planos: ${snapshot.error}',
                style: AppTypography.bodyMedium.copyWith(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData ||
              !(snapshot.data?.success ?? false) ||
              (snapshot.data?.data?.isEmpty ?? true)) {
            return Center(
              child: Text(
                'Nenhum plano disponível no momento.',
                style: AppTypography.bodyMedium.copyWith(color: Colors.grey),
              ),
            );
          } else {
            final planos = snapshot.data!.data!;
            return RefreshIndicator(
              onRefresh: _refreshPlanos,
              color: const Color(0xFFFF312E),
              backgroundColor: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: planos.length,
                itemBuilder: (context, index) {
                  final plano = planos[index];
                  return Card(
                    color: const Color(0xFF1C1C1C),
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plano.nome,
                            style: AppTypography.titleLarge
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plano.descricao,
                            style: AppTypography.bodyMedium
                                .copyWith(color: Colors.grey[400]),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              plano.precoFormatado,
                              style: AppTypography.headlineMedium
                                  .copyWith(color: const Color(0xFFFF312E)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final planoService = PlanoService();
                                final response =
                                    await planoService.escolherPlano(plano.id);

                                if (response.success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Plano ${plano.nome} selecionado com sucesso! Aguardando aprovação do pagamento.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(
                                      context); // Go back to home screen
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message ??
                                          'Erro ao selecionar plano.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF312E),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Escolher Plano',
                                style: AppTypography.bodyLarge
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
