import 'package:flutter/material.dart';
import '../../widgets/page_header.dart';

class AgendamentosPage extends StatelessWidget {
  const AgendamentosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(title: 'Agendamentos'),
      body: const Center(
        child: Text(
          'Agendamentos Works',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
