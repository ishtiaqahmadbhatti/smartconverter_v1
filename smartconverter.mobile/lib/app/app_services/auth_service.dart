import '../app_modules/imports_module.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<void> saveTokens(String access, String refresh, {String? name, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
    if (name != null) await prefs.setString(_userNameKey, name);
    if (email != null) await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String password,
    String? deviceId,
  }) async {
    print('DEBUG: AuthService.register called with deviceId: $deviceId');
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.registerEndpoint}');

    try {
      final response = await post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phone,
          'gender': gender,
          'password': password,
          'device_id': deviceId,
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

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.loginUserListEndpoint}');

    try {
      final response = await post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        // Handle different error message formats (String vs List)
        String errorMessage = 'Login failed';
        final detail = data['detail'];

        if (detail is String) {
          errorMessage = detail;
        } else if (detail is List && detail.isNotEmpty) {
          // FastAPI validation errors are lists
          try {
            errorMessage = detail[0]['msg'] ?? 'Validation error';
          } catch (_) {
            errorMessage = detail.toString();
          }
        } else if (detail != null) {
          errorMessage = detail.toString();
        }

        return {
          'success': false,
          'message': errorMessage
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
