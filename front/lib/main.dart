import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management/pages/personal/personal_aulas_page.dart';
import 'package:gym_management/pages/admin/admin_planos_page.dart';
import 'package:gym_management/pages/admin/admin_mural_page.dart';
import 'package:gym_management/pages/personal/exercicios_page.dart';
import 'package:gym_management/pages/personal/treinos_page.dart';
import 'package:gym_management/pages/personal/personal_categorias_page.dart';
import 'package:gym_management/pages/personal/personal_mural_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'package:gym_management/pages/customer/minhas_cobrancas_page.dart';
import 'package:gym_management/pages/customer/mural_page.dart';
import 'package:gym_management/pages/customer/meus_treinos_page.dart';
import 'pages/customer/buy_plan_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Gestão de Academias',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        // Admin routes
        '/admin/planos': (context) => const AdminPlanosPage(),
        '/admin/mural': (context) => const AdminMuralPage(),
        // Personal trainer routes
        '/personal/aulas': (context) => const PersonalAulasPage(),
        '/personal/treinos': (context) => const TreinosPage(),
        '/personal/mural': (context) => const PersonalMuralPage(),
        '/personal/categorias': (context) => const PersonalCategoriasPage(),
        '/personal/exercicios': (context) => const ExerciciosPage(),
        // Customer routes
        '/customer/treinos': (context) => const MeusTreinosPage(),
        '/customer/comprar-plano': (context) => const BuyPlanPage(),
        '/customer/cobrancas': (context) => const MinhasCobrancasPage(),
        '/customer/mural': (context) => const CustomerMuralPage(),
      },
    );
  }
}

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = AuthService();
    final loggedIn = await authService.isLoggedIn();

    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
