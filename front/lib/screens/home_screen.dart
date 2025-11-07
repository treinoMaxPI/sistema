import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/plano_service.dart';
import '../notifiers/role_selection_notifier.dart';
import '../config/role_config.dart';
import '../widgets/modal_components.dart';
import '../widgets/page_button.dart';
import '../theme/typography.dart';
import 'dart:convert';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userName;
  JwtPayload? _parsedJwt;
  bool _isLoading = true;
  PlanoResponse? _currentPlano;
  bool _hasPlano = false;

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

    if (_parsedJwt?.roles.contains(Role.CUSTOMER) ?? false) {
      await _loadUserPlano();
    }
  }

  Future<void> _loadUserPlano() async {
    setState(() {
      _isLoading = true;
    });
    final planoService = PlanoService();
    final response = await planoService.obterMeuPlano();

    if (response.success && response.data != null) {
      setState(() {
        _currentPlano = response.data;
        _hasPlano = true;
      });
      print(jsonEncode(_currentPlano));
    } else {
      setState(() {
        _currentPlano = null;
        _hasPlano = false;
      });
    }
    setState(() {
      _isLoading = false;
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

        return ModalSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                return RoleSelectionOption(
                  roleName: roleNotifier.getRoleName(role),
                  isSelected: isSelected,
                  onTap: () {
                    if (!isSelected) {
                      roleNotifier.selectRole(role);
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final hasMultipleRoles = (_parsedJwt?.roles.length ?? 0) > 1;

        return ModalSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(userName: _userName),
              const SizedBox(height: 32),
              if (hasMultipleRoles) ...[
                ModalOption(
                  icon: Icons.swap_horiz,
                  title: 'Mudar perspectiva',
                  onTap: () {
                    Navigator.pop(context);
                    _showRoleSelectionModal();
                  },
                ),
                const SizedBox(height: 8),
              ],
              ModalOption(
                icon: Icons.logout,
                title: 'Sair',
                color: const Color(0xFFFF312E),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleButtons() {
    final selectedRole = ref.watch(selectedRoleProvider);

    if (selectedRole == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Text(
            'Nenhuma perspectiva selecionada ou disponível.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final roleButtonsInfo = RoleConfig.getButtonsForRole(selectedRole!);

    if (selectedRole == Role.CUSTOMER) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seu Plano Atual:',
                style: AppTypography.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadUserPlano,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _hasPlano
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF312E), width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentPlano!.nome,
                              style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentPlano!.descricao,
                              style: AppTypography.bodyMedium.copyWith(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _currentPlano!.precoFormatado,
                        style: AppTypography.headlineSmall.copyWith(color: const Color(0xFFFF312E)),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Você não possui um plano ativo.',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/customer/comprar-plano');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF312E),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Comprar Plano',
                        style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth = constraints.maxWidth;
              final double buttonWidth = (totalWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: roleButtonsInfo.map<Widget>((buttonInfo) {
                  return PageButton(
                    icon: buttonInfo.icon,
                    title: buttonInfo.title,
                    description: buttonInfo.description,
                    color: buttonInfo.color,
                    width: buttonWidth,
                    onTap: () {
                      Navigator.pushNamed(context, buttonInfo.route);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double buttonWidth = (totalWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: roleButtonsInfo.map<Widget>((buttonInfo) {
            return PageButton(
              icon: buttonInfo.icon,
              title: buttonInfo.title,
              description: buttonInfo.description,
              color: buttonInfo.color,
              width: buttonWidth,
              onTap: () {
                Navigator.pushNamed(context, buttonInfo.route);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserAvatarButton() {
    return IconButton(
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
    );
  }

  Widget _buildAppBarTitle() {
    return _isLoading
        ? Text(
            'Olá...',
            style: AppTypography.headlineSmall,
          )
        : Text(
            'Olá, ${_userName ?? 'Usuário'}',
            style: AppTypography.headlineSmall,
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
        title: _buildAppBarTitle(),
        actions: [_buildUserAvatarButton()],
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
                    _buildRoleButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
