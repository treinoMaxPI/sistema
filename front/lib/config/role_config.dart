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
    ],
    Role.ADMIN: [
      RoleButtonConfig(
        route: '/admin/planos',
        title: 'Planos',
        description: 'Criar e editar planos',
        icon: Icons.edit_document,
        color: Color(0xFFFF312E),
      ),
    ],
    Role.CUSTOMER: [
      RoleButtonConfig(
        route: '/customer/cobrancas',
        title: 'Minhas Cobranças',
        description: 'Visualize suas cobranças',
        icon: Icons.receipt_long,
        color: Color(0xFF2196F3),
      ),
    ],
  };

  static List<RoleButtonConfig> getButtonsForRole(Role role) {
    return roleButtons[role] ?? [];
  }
}
