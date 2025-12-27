import '../app_modules/imports_module.dart';

class PermissionManager {
  /// Checks if storage permissions are granted based on Android version
  static Future<bool> isStoragePermissionGranted() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkVersion = androidInfo.version.sdkInt;

    if (sdkVersion >= 30) {
      // Android 11+ requires MANAGE_EXTERNAL_STORAGE
      return await Permission.manageExternalStorage.isGranted;
    } else {
      // Android 10 and below use standard storage permissions
      return await Permission.storage.isGranted;
    }
  }

  /// Requests storage permissions based on Android version
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkVersion = androidInfo.version.sdkInt;

    if (sdkVersion >= 30) {
      // Android 11+ requires MANAGE_EXTERNAL_STORAGE
      // This will open the system settings for "All Files Access"
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    } else {
      // Android 10 and below use standard storage permissions
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  /// Opens the app settings if permissions were permanently denied
  static Future<void> openAppSettingsIfDenied() async {
    await openAppSettings();
  }
}
