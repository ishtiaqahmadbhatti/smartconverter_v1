import '../app_modules/imports_module.dart';
import '../app_services/admob_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  bool _isPremium = false;
  bool _isGuest = true;
  String _currentPlan = 'free';
  bool _isLoading = false;
  DateTime? _expiryDate;
  String _userName = 'Guest User';
  String _userEmail = 'Sign in to sync your data';
  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _gender = '';

  bool get isPremium => _isPremium;
  bool get isGuest => _isGuest;
  String get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  DateTime? get expiryDate => _expiryDate;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get phone => _phone;
  String get gender => _gender;
  String? get profileImageUrl => _profileImageUrl;

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  String? _profileImageUrl;

  SubscriptionProvider() {
    _init();
  }

  Future<void> _init() async {
    await checkStatus();
  }

  Future<void> checkStatus() async {
    _isLoading = true;
    notifyListeners();

    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();

    if (isLoggedIn) {
      _isGuest = false;
      final name = await AuthService.getUserName();
      final email = await AuthService.getUserEmail();
      _userName = name ?? 'User';
      _userEmail = email ?? '';

      final result = await SubscriptionService.getSubscriptionStatus();
      if (result['success']) {
        final data = result['data'];
        _updateStateFromData(data);
      } else {
        // Token might be invalid or expired, handle gracefully?
        // For now, if status check fails, assume basic user
      }
    } else {
      _isGuest = true;
      _userName = 'Guest User';
      _userEmail = 'Sign in to sync your data';
      _isPremium = false;
      _currentPlan = 'free';
      _profileImageUrl = null;

      // Start guest session if needed (register device)
      await _registerGuestIfNeeded();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _registerGuestIfNeeded() async {
    // Only register if we haven't stored guest info locally or want to sync
    // For now, let's just ensure we have a device ID and call register
    String? deviceId = await getDeviceId();
    if (deviceId != null) {
      final result = await SubscriptionService.registerGuest(deviceId);
      if (result['success']) {
        final data = result['data'];
        _updateStateFromData(data);
      }
    }
  }

  Future<String?> getDeviceId() async {
    print('DEBUG: SubscriptionProvider.getDeviceId called');
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        print('DEBUG: Android Device ID: ${androidInfo.id}');
        return androidInfo.id; // Unique ID on Android
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // Unique ID on iOS
      }
    } catch (e) {
      print('Error getting device ID: $e');
    }
    return null;
  }

  void _updateStateFromData(Map<String, dynamic> data) {
    // If we are in Guest mode, but the returned data belongs to a registered user (has email),
    // we should treat it as a Free Guest user to respect the "Logout" action.
    if (_isGuest &&
        data['email'] != null &&
        data['email'].toString().isNotEmpty) {
      _isPremium = false;
      _currentPlan = 'free';
      _expiryDate = null;
    } else {
      _isPremium = data['is_premium'] ?? false;
      _currentPlan = data['subscription_plan'] ?? 'free';
      if (data['subscription_expiry'] != null) {
        _expiryDate = DateTime.tryParse(data['subscription_expiry']);
      } else {
        _expiryDate = null;
      }

      // Update profile image if available
      if (data.containsKey('profile_image_url')) {
        _profileImageUrl = data['profile_image_url'];
      }

      _firstName = data['first_name'] ?? '';
      _lastName = data['last_name'] ?? '';
      _phone = data['phone_number'] ?? '';
      _gender = data['gender'] ?? '';

      if (_firstName.isNotEmpty || _lastName.isNotEmpty) {
        _userName = '$_firstName $_lastName'.trim();
      }
    }

    // Check expiry
    if (_isPremium &&
        _expiryDate != null &&
        _expiryDate!.isBefore(DateTime.now())) {
      _isPremium = false;
      _currentPlan = 'free';
    }

    // Update AdMob status
    AdMobService.adsEnabled = !_isPremium;

    notifyListeners();
  }

  Future<bool> upgrade(String planId) async {
    if (_isGuest) {
      return false; // UI should handle redirect to login
    }

    _isLoading = true;
    notifyListeners();

    final result = await SubscriptionService.upgradeSubscription(planId);

    if (result['success']) {
      final data = result['data'];
      _updateStateFromData(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void updateProfileImage(String url) {
    // Note: In a real app we might want to check if this is full URL or relative
    // If relative, prepend base URL. But for now, let's store what we get.
    // Ideally we fetch the Base URL asynchronously, but here we just notify.
    // The UI will likely construct the full URL.
    _profileImageUrl = url;
    notifyListeners();
  }

  // Method to refresh status manually (e.g. after login)
  Future<void> refresh() async {
    await checkStatus();
  }
}
