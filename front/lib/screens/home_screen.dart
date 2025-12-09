import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/plano_service.dart';
import '../services/mural_service.dart';
import '../notifiers/role_selection_notifier.dart';
import '../config/role_config.dart';
import '../widgets/modal_components.dart';
import '../widgets/page_button.dart';
import '../theme/typography.dart';
import '../notifiers/theme_mode_notifier.dart';
import '../notifiers/text_scale_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';

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
  String? _avatarUrl;
  Uint8List? _avatarBytes;
  String? _headerMessage;

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
      final avatar = await _authService.getUserAvatarUrl();

      if (!mounted) return;

      setState(() {
        _userName = userName;
        _parsedJwt = parsedJwt;
        _avatarUrl = avatar;
        _isLoading = false;
        _errorMessage = null;
        final roles = parsedJwt?.roles ?? [];
        _headerMessage = roles.isNotEmpty ? _pickMessage(roles.first) : null;
      });
      await _loadAvatar();

      ref.read(selectedRoleProvider.notifier).initializeRole(parsedJwt);

      // Try to load plan for any authenticated user (backend now allows all roles)
      // Only show plan card in UI for CUSTOMER role (handled in _buildRoleButtons)
      await _loadUserPlano(showLoading: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados do usuário';
      });
    }
  }

  Future<void> _pickAndUpdateAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null || file.name.isEmpty) return;
      final up = await MuralService().uploadImagem(file.bytes!, file.name);
      if (up.success && up.data != null) {
        await _authService.setUserAvatarUrl(up.data!);
        if (!mounted) return;
        setState(() => _avatarUrl = up.data);
        await _loadAvatar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(up.message ?? 'Falha ao enviar imagem')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar avatar: $e')),
      );
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final url = _avatarUrl;
      if (url == null || url.isEmpty) {
        setState(() => _avatarBytes = null);
        return;
      }
      final absolute = url.startsWith('http') ? url : 'http://localhost:8080${url.startsWith('/') ? '' : '/'}$url';
      final token = await _authService.getAccessToken();
      final resp = await http.get(Uri.parse(absolute), headers: token != null ? {'Authorization': 'Bearer $token'} : {});
      if (!mounted) return;
      if (resp.statusCode == 200) {
        setState(() => _avatarBytes = resp.bodyBytes);
      } else {
        setState(() => _avatarBytes = null);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _avatarBytes = null);
    }
  }

  Future<void> _removeAvatar() async {
    try {
      await _authService.clearUserAvatarUrl();
      if (!mounted) return;
      setState(() {
        _avatarUrl = null;
        _avatarBytes = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil removida')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao remover foto: $e')),
      );
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
      ref.read(selectedRoleProvider.notifier).clear();
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
                      setState(() {
                        _headerMessage = _pickMessage(role);
                      });
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

  List<String> _messagesForRole(Role role) {
    switch (role) {
      case Role.CUSTOMER:
        return [
          'Seja bem-vindo! Bom treino hoje.',
          'Você está indo muito bem.',
          'Mantenha o foco e a constância.',
          'Cada treino te aproxima do objetivo.',
          'Hidrate-se e bora treinar.',
        ];
      case Role.PERSONAL:
        return [
          'Vamos dar o nosso melhor hoje.',
          'Seus alunos contam com você.',
          'Planeje e acompanhe cada evolução.',
          'Treino bem feito, resultado garantido.',
          'Inspire pelo exemplo.',
        ];
      case Role.ADMIN:
        return [
          'Ótima gestão começa com bons dados.',
          'A academia está em boas mãos.',
          'Mantenha os planos e o mural atualizados.',
          'Clientes felizes, negócio forte.',
          'Organize, analise e avance.',
        ];
    }
  }

  String _pickMessage(Role role) {
    final list = _messagesForRole(role);
    final r = Random();
    return list[r.nextInt(list.length)];
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
              UserAvatar(userName: _userName, imageUrl: _avatarUrl, editable: true, onEdit: _pickAndUpdateAvatar),
              const SizedBox(height: 24),
              if (_userName != null)
                Text(
                  _userName!,
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
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
              Text(
                'Configurações',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ModalOption(
                icon: Icons.edit,
                title: 'Alterar nome exibido',
                onTap: () {
                  Navigator.pop(context);
                  _showEditDisplayNameDialog();
                },
              ),
              const SizedBox(height: 8),
              ModalOption(
                icon: Icons.color_lens,
                title: 'Alterar tema (claro/escuro)',
                onTap: () {
                  Navigator.pop(context);
                  _showEditThemeDialog();
                },
              ),
              const SizedBox(height: 8),
              ModalOption(
                icon: Icons.text_fields,
                title: 'Tamanho da fonte',
                onTap: () {
                  Navigator.pop(context);
                  _showEditTextScaleDialog();
                },
              ),
              const SizedBox(height: 8),
              ModalOption(
                icon: Icons.delete,
                title: 'Remover foto de perfil',
                color: const Color(0xFFFF312E),
                onTap: () async {
                  Navigator.pop(context);
                  await _removeAvatar();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditDisplayNameDialog() async {
    final controller = TextEditingController(text: _userName ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: Text('Alterar nome exibido', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Nome', labelStyle: TextStyle(color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.7))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) {
                Navigator.of(ctx).pop(false);
                return;
              }
              await _authService.setUserName(newName);
              if (!mounted) return;
              setState(() => _userName = newName);
              Navigator.of(ctx).pop(true);
            },
            child: Text('Salvar', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
          ),
        ],
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome atualizado')),
      );
    }
  }

  Future<void> _showEditTextScaleDialog() async {
    final notifier = ref.read(textScaleProvider.notifier);
    final current = ref.read(textScaleProvider);
    TextScale selected = current;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          title: Text('Tamanho da fonte', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<TextScale>(
                title: Text('Pequeno', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
                value: TextScale.small,
                groupValue: selected,
                onChanged: (v) => setStateDialog(() => selected = v!),
              ),
              RadioListTile<TextScale>(
                title: Text('Normal', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
                value: TextScale.normal,
                groupValue: selected,
                onChanged: (v) => setStateDialog(() => selected = v!),
              ),
              RadioListTile<TextScale>(
                title: Text('Grande', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
                value: TextScale.large,
                groupValue: selected,
                onChanged: (v) => setStateDialog(() => selected = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancelar', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () async {
                if (selected == TextScale.small) {
                  await notifier.setSmall();
                } else if (selected == TextScale.large) {
                  await notifier.setLarge();
                } else {
                  await notifier.setNormal();
                }
                Navigator.of(ctx).pop(true);
              },
              child: Text('Salvar', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
            ),
          ],
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tamanho da fonte atualizado')),
      );
    }
  }

  Future<void> _showEditThemeDialog() async {
    final current = ref.read(themeModeProvider);
    ThemeMode selected = current;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          title: Text('Alterar tema', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text('Modo escuro', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
                value: ThemeMode.dark,
                groupValue: selected,
                onChanged: (v) => setStateDialog(() => selected = v!),
              ),
              RadioListTile<ThemeMode>(
                title: Text('Modo claro', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
                value: ThemeMode.light,
                groupValue: selected,
                onChanged: (v) => setStateDialog(() => selected = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancelar', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () {
                final notifier = ref.read(themeModeProvider.notifier);
                if (selected == ThemeMode.dark) {
                  notifier.setDark();
                } else {
                  notifier.setLight();
                }
                Navigator.of(ctx).pop(true);
              },
              child: Text('Salvar', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
            ),
          ],
        ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tema atualizado')),
      );
    }
  }

  Widget _ThemeOption({required String title, required bool selected, required VoidCallback onTap}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;
    final outline = Theme.of(context).colorScheme.outline;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF312E).withOpacity(0.1) : surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFFF312E) : outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: onSurface,
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
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
                        color: const Color(0xFFFF312E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
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
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentPlano!.descricao,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                              color: null,
                            ),
                          )
                        : Icon(Icons.refresh,
                            color: Theme.of(context).colorScheme.onSurface, size: 20),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
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
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentPlano!.proximoPlanoNome!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
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
                        color: null,
                      ),
                    )
                  : Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurface, size: 20),
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum plano ativo',
            style: AppTypography.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assine um plano para acessar todos os recursos',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
        final double buttonHeight = 150;

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
              height: buttonHeight,
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
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: const Color(0xFFFF312E), width: 2),
        ),
        child: ClipOval(
          child: (_avatarBytes != null)
              ? Image.memory(_avatarBytes!, fit: BoxFit.cover)
              : ((_avatarUrl != null && _avatarUrl!.isNotEmpty)
                  ? Image.network(
                      _avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.person, size: 22, color: const Color(0xFFFF312E)),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.person, size: 22, color: const Color(0xFFFF312E)),
                    )),
        ),
      ),
      onPressed: _showUserMenu,
      tooltip: 'Menu do usuário',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        elevation: 0,
        centerTitle: true,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? const Text('Carregando...', style: AppTypography.headlineSmall)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Olá, ${_userName ?? 'Usuário'}!',
                      style: AppTypography.headlineSmall,
                      key: ValueKey(_userName),
                    ),
                    if (_headerMessage != null)
                      Text(
                        _headerMessage!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                  ],
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
