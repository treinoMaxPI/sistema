import 'package:flutter/material.dart';
import 'package:gym_management/widgets/page_header.dart';
import 'package:gym_management/theme/typography.dart';
import 'package:gym_management/services/usuario_service.dart';

class AdminPersonalsPage extends StatefulWidget {
  const AdminPersonalsPage({super.key});

  @override
  State<AdminPersonalsPage> createState() => _AdminPersonalsPageState();
}

class _AdminPersonalsPageState extends State<AdminPersonalsPage> {
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
    // Reusing listarClientes for now as it fetches users.
    // Ideally we should have a specific endpoint or parameter for all users or potential personals.
    // The backend endpoint /api/usuarios/admin/todos returns all users.
    // We need to update UsuarioService to use that endpoint or adapt listarClientes.
    // For now, let's assume listarClientes fetches what we need or we update it.
    // Actually, I should have updated UsuarioService to use the new endpoint.
    // Let's use a new method in UsuarioService or modify listarClientes.
    // Wait, I didn't add listarTodosAdmin in UsuarioService in the previous step.
    // I will add it now in the service file, but for this file I will assume it exists or use listarClientes.
    // Let's use listarClientes for now and filter or I will fix the service in the next step.
    // Actually, I should fix the service first. But I am already writing this file.
    // I will write this file assuming a method listarTodosAdmin exists, and then I will add it to the service.
    
    final resp = await _service.listarTodosAdmin(); 
    
    if (resp.success && resp.data != null) {
      setState(() {
        _usuarios = resp.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _usuarios = [];
        _error = resp.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _promover(UsuarioResponse usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Promoção'),
        content: Text('Deseja promover ${usuario.nome} a Personal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirm == true) {
      final resp = await _service.promoverParaPersonal(usuario.id);
      if (resp.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário promovido com sucesso!')));
          _carregar();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp.message ?? 'Erro ao promover')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PageHeader(title: 'Gerenciar Personals'),
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
                            _error ?? 'Nenhum usuário encontrado.',
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
                        final isPersonal = u.roles?.contains('PERSONAL') ?? false;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.nome, style: AppTypography.titleMedium.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('Email: ${u.email}', style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                                    const SizedBox(height: 2),
                                    Text('Roles: ${u.roles?.join(", ")}', style: AppTypography.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                                  ],
                                ),
                              ),
                              if (!isPersonal)
                                IconButton(
                                  icon: const Icon(Icons.upgrade),
                                  tooltip: 'Promover a Personal',
                                  onPressed: () => _promover(u),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
