import 'package:flutter/material.dart';
import '../../widgets/page_header.dart';

class MeuTreinoPage extends StatelessWidget {
  const MeuTreinoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(title: 'Meu Treino'),
      body: const Center(
        child: Text(
          'Meu Treino Works',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
