import '../app_modules/imports_module.dart';

class SubscriptionService {
  
  static Future<Map<String, dynamic>> registerGuest(String deviceId) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.guestRegisterEndpoint}');

    try {
      final response = await post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_id': deviceId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Guest registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> upgradeSubscription(String planId) async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.subscriptionUpgradeEndpoint}');
    final token = await AuthService.getAccessToken();

    if (token == null) {
      return {'success': false, 'message': 'Authentication required'};
    }

    try {
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'plan_id': planId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Upgrade failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final baseUrl = await ApiConfig.baseUrl;
    final url = Uri.parse('$baseUrl${ApiConfig.subscriptionStatusEndpoint}');
    final token = await AuthService.getAccessToken();

    if (token == null) {
       return {'success': false, 'message': 'Not logged in'};
    }

    try {
      final response = await get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Failed to get status'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
