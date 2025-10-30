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