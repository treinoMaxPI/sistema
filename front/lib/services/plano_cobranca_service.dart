import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_management/models/paginated_response.dart';
import 'package:gym_management/models/plano_cobranca_customer_response.dart';
import 'package:gym_management/services/plano_service.dart'; // For ApiResponse

class PlanoCobrancaService {
  static const String baseUrl = 'http://localhost:8080/api/customer/cobrancas';

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ApiResponse<PaginatedResponse<PlanoCobrancaCustomerResponse>>>
      getCustomerCobrancas({
    int page = 0,
    int size = 10,
    String sortBy = 'dataVencimento',
    String sortDir = 'desc',
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Token de acesso não encontrado',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl?page=$page&size=$size&sort=$sortBy,$sortDir'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final PaginatedResponse<PlanoCobrancaCustomerResponse> paginatedCobrancas =
            PaginatedResponse.fromJson(
                responseBody, PlanoCobrancaCustomerResponse.fromJson);

        return ApiResponse(success: true, data: paginatedCobrancas);
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erro ao listar cobranças',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Erro de conexão: $e',
      );
    }
  }
}
