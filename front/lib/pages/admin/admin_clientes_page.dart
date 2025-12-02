import 'package:flutter/material.dart';
import 'package:gym_management/widgets/page_header.dart';
import 'package:gym_management/theme/typography.dart';
import 'package:gym_management/services/usuario_service.dart';

class AdminClientesPage extends StatefulWidget {
  const AdminClientesPage({super.key});

  @override
  State<AdminClientesPage> createState() => _AdminClientesPageState();
}

class _AdminClientesPageState extends State<AdminClientesPage> {
  final UsuarioService _service = UsuarioService();
  List<UsuarioResponse> _usuarios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final resp = await _service.listarClientes();
    if (resp.success && resp.data != null) {
      setState(() {
        _usuarios = resp.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _usuarios = [];
        _error = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PageHeader(title: 'Clientes'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              color: const Color(0xFFFF312E),
              child: _usuarios.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Center(
                          child: Text(
                            'Ainda não há clientes.',
                            style: AppTypography.caption.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _usuarios.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final u = _usuarios[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.nome, style: AppTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Email: ${u.email}', style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                              const SizedBox(height: 2),
                              Text('Login: ${u.login}', style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}