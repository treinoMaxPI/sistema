import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

typedef SelectedRoleState = Role?;

class RoleSelectionNotifier extends StateNotifier<SelectedRoleState> {
  RoleSelectionNotifier() : super(null);

  void initializeRole(JwtPayload? parsedJwt) {
    if (parsedJwt != null && parsedJwt.roles.isNotEmpty) {
      // Always update state if it's null or not in the new user's roles
      if (state == null || !parsedJwt.roles.contains(state)) {
        state = parsedJwt.roles.first;
      }
    } else {
      state = null;
    }
  }

  void clear() {
    state = null;
  }

  void selectRole(Role newRole) {
    if (state != newRole) {
      state = newRole;
    }
  }

  String getRoleName(Role? role) {
    switch (role) {
      case Role.PERSONAL:
        return 'Personal Trainer';
      case Role.ADMIN:
        return 'Administrador';
      case Role.CUSTOMER:
        return 'Cliente';
      case null:
        return 'Não Atribuída';
    }
  }
}

final selectedRoleProvider =
    StateNotifierProvider<RoleSelectionNotifier, SelectedRoleState>(
        (ref) => RoleSelectionNotifier());

final selectedRoleNameProvider = Provider<String>((ref) {
  final role = ref.watch(selectedRoleProvider);

  return ref.watch(selectedRoleProvider.notifier).getRoleName(role);
});
