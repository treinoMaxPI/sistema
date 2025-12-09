import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardResponse {
  final int totalRevenueMonthInCents;
  final double percentualRevenueGrowthMonth;
  final int totalNumberMembers;
  final int totalNumberPaidMembers;
  final int totalNumberUnpaidMembers;
  final Map<String, double> userDistributionByPlan;

  AdminDashboardResponse({
    required this.totalRevenueMonthInCents,
    required this.percentualRevenueGrowthMonth,
    required this.totalNumberMembers,
    required this.totalNumberPaidMembers,
    required this.totalNumberUnpaidMembers,
    required this.userDistributionByPlan,
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) {
    return AdminDashboardResponse(
      totalRevenueMonthInCents: json['totalRevenueMonthInCents'] ?? 0,
      percentualRevenueGrowthMonth:
          (json['percentualRevenueGrowthMonth'] ?? 0.0).toDouble(),
      totalNumberMembers: json['totalNumberMembers'] ?? 0,
      totalNumberPaidMembers: json['totalNumberPaidMembers'] ?? 0,
      totalNumberUnpaidMembers: json['totalNumberUnpaidMembers'] ?? 0,
      userDistributionByPlan: json['userDistributionByPlan'] != null
          ? Map<String, double>.from(json['userDistributionByPlan'])
          : <String, double>{},
    );
  }

  double get totalRevenueMonthInReais => totalRevenueMonthInCents / 100.0;
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

class DashboardService {
  static const String baseUrl = 'http://localhost:8080/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<AdminDashboardResponse>> getAdminDashboard() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(
            success: false, message: 'Token de acesso não encontrado');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/admin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.isEmpty) {
          return ApiResponse(
            success: false,
            message: 'Resposta vazia do servidor',
          );
        }
        try {
          final data = json.decode(body);
          final dashboardData = AdminDashboardResponse.fromJson(data);
          return ApiResponse(success: true, data: dashboardData);
        } catch (e) {
          return ApiResponse(
            success: false,
            message: 'Erro ao processar resposta: $e',
          );
        }
      } else {
        final body = response.body.trim();
        if (body.isNotEmpty) {
          try {
            final errorData = json.decode(body);
            return ApiResponse(
              success: false,
              message: errorData['message'] ?? 'Erro ao carregar dashboard',
            );
          } catch (e) {
            return ApiResponse(
              success: false,
              message: 'Erro HTTP ${response.statusCode}: $body',
            );
          }
        } else {
          return ApiResponse(
            success: false,
            message: 'Erro HTTP ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }
}
