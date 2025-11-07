import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_management/pages/admin/admin_planos_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'pages/personal/personal_screen.dart';
import 'pages/admin/admin_screen.dart';
import 'pages/customer/customer_screen.dart';
import 'pages/admin/dashboard_page.dart';
import 'pages/admin/usuarios_page.dart';
import 'pages/admin/relatorios_page.dart';
import 'pages/admin/configuracoes_page.dart';
import 'pages/personal/meus_treinos_page.dart';
import 'pages/personal/meus_alunos_page.dart';
import 'pages/personal/agendamentos_page.dart';
import 'pages/customer/meu_treino_page.dart';
import 'pages/customer/agendar_sessao_page.dart';
import 'pages/customer/meu_progresso_page.dart';
import 'screens/buy_plan_screen.dart';

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
        '/personal': (context) => const PersonalScreen(),
        '/admin': (context) => const AdminScreen(),
        '/customer': (context) => const CustomerScreen(),
        // Admin routes
        '/admin/dashboard': (context) => const DashboardPage(),
        '/admin/usuarios': (context) => const UsuariosPage(),
        '/admin/relatorios': (context) => const RelatoriosPage(),
        '/admin/configuracoes': (context) => const ConfiguracoesPage(),
        '/admin/planos': (context) => const AdminPlanosPage(),
        // Personal trainer routes
        '/personal/treinos': (context) => const MeusTreinosPage(),
        '/personal/alunos': (context) => const MeusAlunosPage(),
        '/personal/agendamentos': (context) => const AgendamentosPage(),
        // Customer routes
        '/customer/meu-treino': (context) => const MeuTreinoPage(),
        '/customer/agendamentos': (context) => const AgendarSessaoPage(),
        '/customer/progresso': (context) => const MeuProgressoPage(),
        '/customer/comprar-plano': (context) => const BuyPlanScreen(),
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
