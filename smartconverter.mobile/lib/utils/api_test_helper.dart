import '../services/conversion_service.dart';

/// Helper class to test API connection and functionality
class ApiTestHelper {
  static final ConversionService _conversionService = ConversionService();

  /// Test the API connection
  static Future<void> testApiConnection() async {
    print('🔍 Testing API connection...');

    try {
      await _conversionService.initialize();
      bool isConnected = await _conversionService.testConnection();

      if (isConnected) {
        print(
          '✅ Successfully connected to FastAPI backend at http://192.168.8.100:8000',
        );
        print('🚀 API is ready for file conversions!');
      } else {
        print('❌ Failed to connect to FastAPI backend');
        print(
          '📋 Please ensure your FastAPI server is running on http://192.168.8.100:8000',
        );
        print(
          '💡 You can test your API by visiting: http://192.168.8.100:8000/docs',
        );
      }
    } catch (e) {
      print('❌ Error testing API connection: $e');
      print('📋 Please check:');
      print('   1. FastAPI server is running on http://192.168.8.100:8000');
      print('   2. The /health endpoint is available');
      print('   3. No firewall is blocking the connection');
    }
  }

  /// Display API configuration information
  static void displayApiConfig() {
    print('📡 API Configuration:');
    print('   Base URL: http://192.168.8.100:8000');
    print('   Connect Timeout: 30 seconds');
    print('   Receive Timeout: 60 seconds');
    print('   Max File Size: 50MB');
    print('');
    print('🛠️  Available Endpoints:');
    print('   Health Check: /api/v1/health/health');
    print('   PDF to Word: /convert/pdf-to-word');
    print('   Word to PDF: /convert/word-to-pdf');
    print('   Images to PDF: /convert/images-to-pdf');
    print('   PDF to Images: /convert/pdf-to-images');
    print('   Merge PDF: /convert/merge-pdf');
    print('   Split PDF: /convert/split-pdf');
    print('   Compress PDF: /convert/compress-pdf');
    print('');
  }
}
