import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RoleColors {
  static const Map<Role, Color> _primaryColors = {
    Role.PERSONAL: Color(0xFF4CAF50), 
    Role.CUSTOMER: Color(0xFF2196F3),   
    Role.ADMIN: Color(0xFFFF312E),    
  };

  static Color getPrimaryColor(Role role) {
    return _primaryColors[role] ?? const Color(0xFFFF312E);
  }

  static Future<Color> getPrimaryColorFromToken() async {
    final payload = await AuthService().getParsedAccessToken();
    if (payload != null && payload.roles.isNotEmpty) {
      return getPrimaryColor(payload.roles.first);
    }
    return const Color(0xFFFF312E);
  }
}
