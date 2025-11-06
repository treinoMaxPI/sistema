import 'package:flutter/material.dart';
import '../../widgets/page_header.dart';

class MeuProgressoPage extends StatelessWidget {
  const MeuProgressoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(title: 'Meu Progresso'),
      body: const Center(
        child: Text(
          'Meu Progresso Works',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
