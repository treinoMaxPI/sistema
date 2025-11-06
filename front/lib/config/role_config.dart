import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RoleButtonConfig {
  final String route;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const RoleButtonConfig({
    required this.route,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class RoleConfig {
  static const Map<Role, List<RoleButtonConfig>> roleButtons = {
    Role.PERSONAL: [
      RoleButtonConfig(
        route: '/personal/treinos',
        title: 'Meus Treinos',
        description: 'Visualize seus treinos',
        icon: Icons.fitness_center,
        color: Color(0xFF4CAF50),
      ),
      RoleButtonConfig(
        route: '/personal/alunos',
        title: 'Meus Alunos',
        description: 'Gerencie seus alunos',
        icon: Icons.group,
        color: Color(0xFF4CAF50),
      ),
      RoleButtonConfig(
        route: '/personal/agendamentos',
        title: 'Agendamentos',
        description: 'Suas sessões agendadas',
        icon: Icons.calendar_today,
        color: Color(0xFF4CAF50),
      ),
    ],
    Role.ADMIN: [
      RoleButtonConfig(
        route: '/admin/dashboard',
        title: 'Dashboard',
        description: 'Visão geral do sistema',
        icon: Icons.dashboard,
        color: Color(0xFFFF312E),
      ),
      RoleButtonConfig(
        route: '/admin/usuarios',
        title: 'Usuários',
        description: 'Gerencie usuários',
        icon: Icons.people,
        color: Color(0xFFFF312E),
      ),
      RoleButtonConfig(
        route: '/admin/relatorios',
        title: 'Relatórios',
        description: 'Relatórios e estatísticas',
        icon: Icons.assessment,
        color: Color(0xFFFF312E),
      ),
      RoleButtonConfig(
        route: '/admin/configuracoes',
        title: 'Configurações',
        description: 'Configurações do sistema',
        icon: Icons.settings,
        color: Color(0xFFFF312E),
      ),
    ],
    Role.CUSTOMER: [
      RoleButtonConfig(
        route: '/customer/meu-treino',
        title: 'Meu Treino',
        description: 'Seu plano de treino',
        icon: Icons.fitness_center,
        color: Color(0xFF2196F3),
      ),
      RoleButtonConfig(
        route: '/customer/agendamentos',
        title: 'Agendar Sessão',
        description: 'Agende com seu personal',
        icon: Icons.event,
        color: Color(0xFF2196F3),
      ),
      RoleButtonConfig(
        route: '/customer/progresso',
        title: 'Meu Progresso',
        description: 'Acompanhe sua evolução',
        icon: Icons.trending_up,
        color: Color(0xFF2196F3),
      ),
    ],
  };

  static List<RoleButtonConfig> getButtonsForRole(Role role) {
    return roleButtons[role] ?? [];
  }
}
