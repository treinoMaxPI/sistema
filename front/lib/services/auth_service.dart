import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum Role { ADMIN, PERSONAL, CUSTOMER }

class LoginRequest {
  final String email;
  final String senha;

  LoginRequest({
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'senha': senha,
    };
  }
}

class RegisterRequest {
  final String nome;
  final String email;
  final String senha;

  RegisterRequest({
    required this.nome,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }
}

class LoginResponse {
  final String token;
  final String refreshToken;
  final String nome;
  final String email;
  final bool emailVerificado;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.nome,
    required this.email,
    required this.emailVerificado,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      nome: json['nome'],
      email: json['email'],
      emailVerificado: json['emailVerificado'],
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });
}

class JwtPayload {
  final String sub;
  final String id;
  final String nome;
  final bool emailVerificado;
  final List<Role> roles;
  final int iat;
  final int exp;

  JwtPayload({
    required this.sub,
    required this.id,
    required this.nome,
    required this.emailVerificado,
    required this.roles,
    required this.iat,
    required this.exp,
  });

  factory JwtPayload.fromJson(Map<String, dynamic> json) {
    final List<Role> roles = [];
    for (final role in json['roles']) {
      switch (role) {
        case 'ADMIN':
          roles.add(Role.ADMIN);
          break;
        case 'PERSONAL':
          roles.add(Role.PERSONAL);
          break;
        case 'CUSTOMER':
          roles.add(Role.CUSTOMER);
          break;
        default:
          roles.add(Role.CUSTOMER);
      }
    }

    return JwtPayload(
      sub: json['sub'],
      id: json['id'],
      nome: json['nome'],
      emailVerificado: json['emailVerificado'],
      roles: roles,
      iat: json['iat'],
      exp: json['exp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'id': id,
      'nome': nome,
      'emailVerificado': emailVerificado,
      'roles': roles.map((role) => role.name).toList(),
      'iat': iat,
      'exp': exp,
    };
  }
}

class AuthService {
  static const String baseUrl = 'http:

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final loginResponse =
            LoginResponse.fromJson(json.decode(response.body));

        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', loginResponse.token);
        await prefs.setString('refreshToken', loginResponse.refreshToken);
        await prefs.setString('userName', loginResponse.nome);
        await prefs.setString('userEmail', loginResponse.email);

        return ApiResponse(success: true, data: loginResponse);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao fazer login',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<void>> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201) {
        return ApiResponse(success: true);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao criar conta',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ?? 'Erro ao solicitar recuperação de senha',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<ApiResponse<void>> resendVerification(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-verification?email=$email'),
        
        
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao reenviar verificação',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refreshToken': refreshToken}),
        );
      } catch (e) {}
    }

    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Future<JwtPayload?> getParsedAccessToken() async {
    final token = await getAccessToken();
    return _parseJwt(token);
  }

  JwtPayload? _parseJwt(String? token) {
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      return JwtPayload.fromJson(payloadMap);
    } catch (e) {
      return null;
    }
  }
}
