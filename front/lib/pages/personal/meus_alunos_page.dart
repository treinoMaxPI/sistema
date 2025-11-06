import 'package:flutter/material.dart';
import '../../widgets/page_header.dart';

class MeusAlunosPage extends StatelessWidget {
  const MeusAlunosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(title: 'Meus Alunos'),
      body: const Center(
        child: Text(
          'Meus Alunos Works',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
