import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String password,
  }) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.registerEndpoint}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phone,
          'gender': gender,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
