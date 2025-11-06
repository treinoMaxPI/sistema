import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

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
    });
  }

  Future<void> _logout() async {
    final authService = AuthService();
    await authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showUserMenu() {
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
              // Indicador de arraste
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar e informações do usuário
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
                      _parsedJwt!.roles.first.toString(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // Opções do menu
              if (hasMultipleRoles) ...[
                _buildMenuOption(
                  icon: Icons.swap_horiz,
                  title: 'Mudar perspectiva',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Funcionalidade em desenvolvimento'),
                        backgroundColor: Colors.grey[800],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
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
          : Container(),
    );
  }
}
