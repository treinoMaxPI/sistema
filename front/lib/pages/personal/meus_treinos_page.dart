import 'package:flutter/material.dart';
import '../../widgets/page_header.dart';

class MeusTreinosPage extends StatelessWidget {
  const MeusTreinosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(title: 'Meus Treinos'),
      body: const Center(
        child: Text(
          'Meus Treinos Works',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
