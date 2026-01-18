import '../app_modules/imports_module.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Biometric Constants
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricEmailKey = 'biometric_email';
  static const String _biometricPasswordKey = 'biometric_password';

  static const _secureStorage = FlutterSecureStorage();

  static Future<void> saveTokens(
    String access,
    String refresh, {
    String? name,
    String? email,
  }) async {
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
          'message': data['detail'] ?? 'Registration failed',
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
        body: jsonEncode({'email': email, 'password': password}),
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

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.changePasswordEndpoint}');
    final token = await getAccessToken();

    if (token == null) {
      return {'success': false, 'message': 'Not logged in'};
    }

    try {
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? gender,
  }) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.updateProfileEndpoint}');
    final token = await getAccessToken();

    if (token == null) {
      return {'success': false, 'message': 'Not logged in'};
    }

    try {
      final response = await put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (email != null) 'email': email,
          if (phone != null) 'phone_number': phone,
          if (gender != null) 'gender': gender,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update local stored name if changed
        if (firstName != null || lastName != null) {
          final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userNameKey, fullName);
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // 1. Send OTP
  static Future<Map<String, dynamic>> sendOtp({
    required String email,
    String? deviceId,
  }) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.forgotPasswordEndpoint}');

    try {
      final response = await post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'device_id': deviceId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Verification code sent',
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Failed to send verification code',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // 2. Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.verifyOtpEndpoint}');

    try {
      final response = await post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp_code': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Verified',
          'reset_token': data['reset_token'],
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // 4. Upload Profile Image
  static Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.uploadProfileImageEndpoint}');
    final token = await getAccessToken();

    if (token == null) {
      return {'success': false, 'message': 'Not logged in'};
    }

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile image uploaded successfully',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Failed to upload image',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // 3. Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.resetPasswordEndpoint}');

    try {
      final response = await post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reset_token': resetToken,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password reset successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // --- Biometric Authentication Helpers ---

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    if (!enabled) {
      // If disabling, clear stored credentials for security
      await clearBiometricCredentials();
    }
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  static Future<void> saveCredentialsForBiometric(
    String email,
    String password,
  ) async {
    await _secureStorage.write(key: _biometricEmailKey, value: email);
    await _secureStorage.write(key: _biometricPasswordKey, value: password);
    await setBiometricEnabled(true);
  }

  static Future<Map<String, String?>> getBiometricCredentials() async {
    final email = await _secureStorage.read(key: _biometricEmailKey);
    final password = await _secureStorage.read(key: _biometricPasswordKey);
    return {'email': email, 'password': password};
  }

  static Future<void> clearBiometricCredentials() async {
    await _secureStorage.delete(key: _biometricEmailKey);
    await _secureStorage.delete(key: _biometricPasswordKey);
  }
}
