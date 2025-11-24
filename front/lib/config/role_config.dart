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
        route: '/personal/mural',
        title: 'Mural da Academia',
        description: 'Poste avisos e novidades',
        icon: Icons.campaign,
        color: Color(0xFF4CAF50),
      ),
       RoleButtonConfig(
        route: '/personal/aulas',
        title: 'Gerenciar Aulas',
        description: 'Crie e edite aulas',
        icon: Icons.class_,
        color: Color(0xFF4CAF50),
      ),
       RoleButtonConfig(
        route: '/personal/categorias',
        title: 'Gerenciar Categorias',
        description: 'Crie e edite categorias',
        icon: Icons.class_,
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
      RoleButtonConfig(
        route: '/admin/mural',
        title: 'Mural da Academia',
        description: 'Poste avisos e novidades',
        icon: Icons.campaign,
        color: Color(0xFFFF312E),
      ),
      RoleButtonConfig(
        route: '/admin/clientes',
        title: 'Clientes',
        description: 'Visualizar clientes',
        icon: Icons.group,
        color: Color(0xFFFF312E),
      ),
      RoleButtonConfig(
        route: '/admin/relatorios',
        title: 'Relatórios',
        description: 'Entradas/Saídas e Pagamentos',
        icon: Icons.insights,
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
      RoleButtonConfig(
        route: '/customer/mural',
        title: 'Mural da Academia',
        description: 'Veja avisos e novidades',
        icon: Icons.campaign,
        color: Color(0xFF2196F3),
      ),
    ],
  };

  static List<RoleButtonConfig> getButtonsForRole(Role role) {
    return roleButtons[role] ?? [];
  }
}
