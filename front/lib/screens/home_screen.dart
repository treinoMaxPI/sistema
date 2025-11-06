import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../notifiers/role_selection_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userName;
  JwtPayload? _parsedJwt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final userName = await authService.getUserName();
    final parsedJwt = await authService.getParsedAccessToken();

    setState(() {
      _userName = userName;
      _parsedJwt = parsedJwt;
      _isLoading = false;

      ref.read(selectedRoleProvider.notifier).initializeRole(parsedJwt);
    });
  }

  Future<void> _logout() async {
    final authService = AuthService();
    await authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showRoleSelectionModal() {
    final roles = _parsedJwt?.roles ?? [];
    if (roles.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final selectedRole = ref.watch(selectedRoleProvider);
        final roleNotifier = ref.read(selectedRoleProvider.notifier);

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mudar Perspectiva',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...roles.map((role) {
                final isSelected = role == selectedRole;
                return _buildRoleSelectionOption(
                  role: role,
                  isSelected: isSelected,
                  onTap: () {
                    if (!isSelected) {
                      roleNotifier.selectRole(role);
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Perspectiva alterada para ${roleNotifier.getRoleName(role)}'),
                        backgroundColor: const Color(0xFFFF312E),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              }).toList(),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleSelectionOption({
    required Role role,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final roleNotifier = ref.read(selectedRoleProvider.notifier);
    final roleName = roleNotifier.getRoleName(role);
    final color = isSelected ? const Color(0xFFFF312E) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF312E).withOpacity(0.15)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF312E) : Colors.grey[800]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                roleName,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFF312E),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu() {
    final currentRoleName = ref.read(selectedRoleNameProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final hasMultipleRoles = (_parsedJwt?.roles.length ?? 0) > 1;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(
                        color: const Color(0xFFFF312E),
                        width: 3,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFFFF312E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName ?? 'Usuário',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_parsedJwt?.roles.isNotEmpty ?? false)
                    Text(
                      currentRoleName,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              if (hasMultipleRoles) ...[
                _buildMenuOption(
                  icon: Icons.swap_horiz,
                  title: 'Mudar perspectiva',
                  onTap: () {
                    Navigator.pop(context);
                    _showRoleSelectionModal();
                  },
                ),
                const SizedBox(height: 8),
              ],
              _buildMenuOption(
                icon: Icons.logout,
                title: 'Sair',
                color: const Color(0xFFFF312E),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: optionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: optionColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: optionColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: optionColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRoleButtonsMap(Role role) {
    final Map<Role, List<Map<String, dynamic>>> roleButtons = {
      Role.PERSONAL: [
        {
          'route': '/personal/treinos',
          'title': 'Meus Treinos',
          'description': 'Visualize seus treinos',
          'icon': Icons.fitness_center,
          'color': const Color(0xFF4CAF50),
        },
        {
          'route': '/personal/alunos',
          'title': 'Meus Alunos',
          'description': 'Gerencie seus alunos',
          'icon': Icons.group,
          'color': const Color(0xFF4CAF50),
        },
        {
          'route': '/personal/agendamentos',
          'title': 'Agendamentos',
          'description': 'Suas sessões agendadas',
          'icon': Icons.calendar_today,
          'color': const Color(0xFF4CAF50),
        },
      ],
      Role.ADMIN: [
        {
          'route': '/admin/dashboard',
          'title': 'Dashboard',
          'description': 'Visão geral do sistema',
          'icon': Icons.dashboard,
          'color': const Color(0xFFFF312E),
        },
        {
          'route': '/admin/usuarios',
          'title': 'Usuários',
          'description': 'Gerencie usuários',
          'icon': Icons.people,
          'color': const Color(0xFFFF312E),
        },
        {
          'route': '/admin/relatorios',
          'title': 'Relatórios',
          'description': 'Relatórios e estatísticas',
          'icon': Icons.assessment,
          'color': const Color(0xFFFF312E),
        },
        {
          'route': '/admin/configuracoes',
          'title': 'Configurações',
          'description': 'Configurações do sistema',
          'icon': Icons.settings,
          'color': const Color(0xFFFF312E),
        },
      ],
      Role.CUSTOMER: [
        {
          'route': '/customer/meu-treino',
          'title': 'Meu Treino',
          'description': 'Seu plano de treino',
          'icon': Icons.fitness_center,
          'color': const Color(0xFF2196F3),
        },
        {
          'route': '/customer/agendamentos',
          'title': 'Agendar Sessão',
          'description': 'Agende com seu personal',
          'icon': Icons.event,
          'color': const Color(0xFF2196F3),
        },
        {
          'route': '/customer/progresso',
          'title': 'Meu Progresso',
          'description': 'Acompanhe sua evolução',
          'icon': Icons.trending_up,
          'color': const Color(0xFF2196F3),
        },
      ],
    };

    return roleButtons[role] ?? [];
  }

  List<Widget> _buildRoleButtons() {
    final selectedRole = ref.watch(selectedRoleProvider);
    final roleNotifier = ref.read(selectedRoleProvider.notifier);

    final List<Widget> sections = [];

    if (selectedRole == null) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Center(
            child: Text(
              'Nenhuma perspectiva selecionada ou disponível.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        )
      ];
    }

    final roleButtonsInfo = _getRoleButtonsMap(selectedRole);

    if (roleButtonsInfo.isEmpty) {
      sections.add(
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                roleNotifier.getRoleName(selectedRole),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
      sections.add(
        const Text(
          'Nenhum botão de ação definido para esta perspectiva.',
          style: TextStyle(color: Colors.grey),
        ),
      );
      return sections;
    }

    final sectionColor = roleButtonsInfo.first['color'] as Color;

    sections.add(
      Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              roleNotifier.getRoleName(selectedRole),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    const double spacing = 12.0;

    sections.add(
      LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          final double buttonWidth = (totalWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: roleButtonsInfo.map<Widget>((buttonInfo) {
              return _buildPageButton(
                icon: buttonInfo['icon'] as IconData,
                title: buttonInfo['title'] as String,
                description: buttonInfo['description'] as String,
                color: buttonInfo['color'] as Color,
                width: buttonWidth,
                onTap: () {
                  Navigator.pushNamed(context, buttonInfo['route'] as String);
                },
              );
            }).toList(),
          );
        },
      ),
    );

    return sections;
  }

  Widget _buildPageButton({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        elevation: 0,
        title: _isLoading
            ? const Text(
                'Olá...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Olá, ${_userName ?? 'Usuário'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
        actions: [
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(
                  color: const Color(0xFFFF312E),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: Color(0xFFFF312E),
                ),
              ),
            ),
            onPressed: _showUserMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildRoleButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
