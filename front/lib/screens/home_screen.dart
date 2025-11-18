import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/plano_service.dart';
import '../notifiers/role_selection_notifier.dart';
import '../config/role_config.dart';
import '../widgets/modal_components.dart';
import '../widgets/page_button.dart';
import '../theme/typography.dart';
import '../notifiers/theme_mode_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _userName;
  JwtPayload? _parsedJwt;
  bool _isLoading = true;
  bool _isRefreshing = false;
  MeuPlanoResponse? _currentPlano;
  bool _hasPlano = false;
  String? _errorMessage;

  late final AuthService _authService;
  late final PlanoService _planoService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _planoService = PlanoService();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userName = await _authService.getUserName();
      final parsedJwt = await _authService.getParsedAccessToken();

      if (!mounted) return;

      setState(() {
        _userName = userName;
        _parsedJwt = parsedJwt;
        _isLoading = false;
        _errorMessage = null;
      });

      ref.read(selectedRoleProvider.notifier).initializeRole(parsedJwt);

      if (_parsedJwt?.roles.contains(Role.CUSTOMER) ?? false) {
        await _loadUserPlano(showLoading: false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados do usuário';
      });
    }
  }

  Future<void> _loadUserPlano({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isRefreshing = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final response = await _planoService.obterMeuPlano();

      if (!mounted) return;

      if (response.success) {
        setState(() {
          _currentPlano = response.data;
          _hasPlano = response.data != null;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _currentPlano = null;
          _hasPlano = false;
          _errorMessage = response.message ?? 'Erro ao carregar plano';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentPlano = null;
        _hasPlano = false;
        _errorMessage = 'Erro ao carregar plano';
      });
      debugPrint('Erro ao carregar plano: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text('Confirmar Saída',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deseja realmente sair?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF312E),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showRoleSelectionModal() {
    final roles = _parsedJwt?.roles ?? [];
    if (roles.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              const SizedBox(height: 8),
              Text(
                'Selecione como deseja visualizar o sistema',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
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

                      if (role == Role.CUSTOMER) {
                        _loadUserPlano(showLoading: false);
                      }
                    }
                    Navigator.pop(context);
                  },
                );
              }),
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
      isScrollControlled: true,
      builder: (context) {
        final hasMultipleRoles = (_parsedJwt?.roles.length ?? 0) > 1;

        return ModalSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(userName: _userName),
              const SizedBox(height: 24),
              if (_userName != null)
                Text(
                  _userName!,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 8),
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
                icon: Icons.settings,
                title: 'Configurações',
                onTap: () {
                  Navigator.pop(context);
                  _showSettingsModal();
                },
              ),
              const SizedBox(height: 8),
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

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final current = ref.watch(themeModeProvider);
        final notifier = ref.read(themeModeProvider.notifier);
        return ModalSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configurações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tema do aplicativo',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _ThemeOption(
                title: 'Modo escuro',
                selected: current == ThemeMode.dark,
                onTap: () => notifier.setDark(),
              ),
              const SizedBox(height: 8),
              _ThemeOption(
                title: 'Modo claro',
                selected: current == ThemeMode.light,
                onTap: () => notifier.setLight(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ThemeOption({required String title, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF312E).withOpacity(0.15) : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFFF312E) : const Color(0xFF2A2A2A),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (selected)
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

  Widget _buildPlanoCard() {
    if (!_hasPlano) {
      return _buildNoPlanoCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1C1C1C), Color(0xFF2A2A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF312E), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF312E).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF312E).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PLANO ATUAL',
                        style: TextStyle(
                          color: Color(0xFFFF312E),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentPlano!.nome,
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentPlano!.descricao,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey[400],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh,
                            color: Colors.white, size: 20),
                    onPressed: _isRefreshing ? null : _loadUserPlano,
                    tooltip: 'Atualizar plano',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentPlano!.precoFormatado,
                    style: AppTypography.headlineLarge.copyWith(
                      color: const Color(0xFFFF312E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/mês',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_currentPlano!.proximoPlanoNome != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.blue[300],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plano agendado para próximo mês',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentPlano!.proximoPlanoNome!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/customer/comprar-plano');
            },
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('Alterar Plano'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF312E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
              shadowColor: const Color(0xFFFF312E).withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoPlanoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white, size: 20),
                onPressed: _isRefreshing ? null : _loadUserPlano,
                tooltip: 'Atualizar plano',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum plano ativo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assine um plano para acessar todos os recursos',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/customer/comprar-plano');
              },
              icon: const Icon(Icons.add_shopping_cart, size: 20),
              label: const Text('Comprar Plano'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF312E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: const Color(0xFFFF312E).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButtons() {
    final selectedRole = ref.watch(selectedRoleProvider);

    if (selectedRole == null) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma perspectiva selecionada',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    final roleButtonsInfo = RoleConfig.getButtonsForRole(selectedRole);

    if (selectedRole == Role.CUSTOMER) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanoCard(),
          const SizedBox(height: 16),
          _buildButtonGrid(roleButtonsInfo),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildButtonGrid(roleButtonsInfo),
      ],
    );
  }

  Widget _buildButtonGrid(List<dynamic> roleButtonsInfo) {
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
              onTap: () => Navigator.pushNamed(context, buttonInfo.route),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1C1C), Color(0xFF2A2A2A)],
          ),
          border: Border.all(color: const Color(0xFFFF312E), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF312E).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.person, size: 22, color: Color(0xFFFF312E)),
        ),
      ),
      onPressed: _showUserMenu,
      tooltip: 'Menu do usuário',
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? const Text('Carregando...', style: AppTypography.headlineSmall)
              : Text(
                  'Olá, ${_userName ?? 'Usuário'}',
                  style: AppTypography.headlineSmall,
                  key: ValueKey(_userName),
                ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildUserAvatarButton(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF312E)),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadUserData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF312E),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  color: const Color(0xFFFF312E),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                ),
    );
  }
}
