import 'package:flutter/material.dart';
import '../../widgets/page_header.dart';

class AgendarSessaoPage extends StatelessWidget {
  const AgendarSessaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(title: 'Agendar Sessão'),
      body: const Center(
        child: Text(
          'Agendar Sessão Works',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
