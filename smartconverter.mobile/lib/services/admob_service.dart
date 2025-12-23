import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// AdMob Service for managing rewarded ads
/// Uses test ad unit IDs for testing
class AdMobService {
  /// Global control for ads (Developer side)
  static bool adsEnabled = true;

  // Granular Ad Controls
  static bool bannerAdsEnabled = false;
  static bool interstitialAdsEnabled = false;
  static bool rewardedAdsEnabled = true;
  static bool appOpenAdsEnabled = true;

  // Test Rewarded Ad Unit ID
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/3419835294';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  RewardedAd? _rewardedAd;
  bool _isAdReady = false;
  bool _isLoading = false;
  static AppOpenAd? _appOpenAd;
  static bool _isAppOpenLoading = false;
  static bool _isShowingAppOpenAd = false;
  
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;
  bool _isInterstitialLoading = false;

  /// Get the rewarded ad unit ID (using test ads)
  static String get rewardedAdUnitId {
    // Currently using test ads only
    return _testRewardedAdUnitId;
  }

  /// Get banner ad unit ID (using test ads)
  static String get bannerAdUnitId => _testBannerAdUnitId;

  /// Get app open ad unit ID (using test ads)
  static String get appOpenAdUnitId => _testAppOpenAdUnitId;

  /// Get interstitial ad unit ID (using test ads)
  static String get interstitialAdUnitId => _testInterstitialAdUnitId;

  /// Check if AdMob is supported on current platform
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;

  /// Initialize AdMob SDK
  static Future<void> initialize() async {
    // Only initialize on Android and iOS and if ads are enabled
    if (!isSupported) {
      debugPrint('⚠️ AdMob not supported on ${Platform.operatingSystem}');
      return;
    }

    if (!adsEnabled) {
      debugPrint('🚫 AdMob initialization skipped: adsEnabled is false');
      return;
    }

    try {
      await MobileAds.instance.initialize();

      // Request configuration
      final configuration = RequestConfiguration(
        testDeviceIds: kDebugMode
            ? ['YOUR_TEST_DEVICE_ID'] // Add your test device ID
            : [],
      );
      MobileAds.instance.updateRequestConfiguration(configuration);

      debugPrint('✅ AdMob initialized successfully');
    } catch (e) {
      debugPrint('⚠️ AdMob initialization failed: $e');
    }
  }

  /// Load a rewarded ad
  Future<void> loadRewardedAd() async {
    if (!isSupported || !adsEnabled || !rewardedAdsEnabled) return;
    
    if (_isLoading || _isAdReady) {
      debugPrint('⚠️ Ad already loading or ready');
      return;
    }

    try {
      _isLoading = true;
      debugPrint('🔄 Loading rewarded ad...');

      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('✅ Rewarded ad loaded successfully');
            _rewardedAd = ad;
            _isAdReady = true;
            _isLoading = false;

            // Set full screen content callback
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                debugPrint('✅ Ad dismissed');
                ad.dispose();
                _rewardedAd = null;
                _isAdReady = false;
              },
              onAdFailedToShowFullScreenContent:
                  (RewardedAd ad, AdError error) {
                    debugPrint('❌ Ad failed to show: ${error.message}');
                    ad.dispose();
                    _rewardedAd = null;
                    _isAdReady = false;
                  },
              onAdShowedFullScreenContent: (RewardedAd ad) {
                debugPrint('📺 Ad showed full screen content');
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('❌ Failed to load rewarded ad: ${error.message}');
            _isLoading = false;
            _isAdReady = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error loading rewarded ad: $e');
      _isLoading = false;
      _isAdReady = false;
    }
  }

  /// Show rewarded ad
  /// Returns true if ad was shown and user earned reward, false otherwise
  Future<bool> showRewardedAd({
    required Function(RewardItem) onRewarded,
    Function(String)? onFailed,
  }) async {
    if (!isSupported || !adsEnabled || !rewardedAdsEnabled) return false;
    
    if (!_isAdReady || _rewardedAd == null) {
      debugPrint('⚠️ Ad not ready, attempting to load...');
      await loadRewardedAd();

      // Wait a bit for ad to load
      await Future.delayed(const Duration(seconds: 2));

      if (!_isAdReady || _rewardedAd == null) {
        debugPrint('❌ Ad still not ready after loading attempt');
        onFailed?.call('Ad not available. Please try again.');
        return false;
      }
    }

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('🎉 User earned reward: ${reward.amount} ${reward.type}');
          onRewarded(reward);

          // Dispose ad after showing
          _rewardedAd?.dispose();
          _rewardedAd = null;
          _isAdReady = false;

          // Load next ad
          loadRewardedAd();
        },
      );
      return true;
    } catch (e) {
      debugPrint('❌ Error showing rewarded ad: $e');
      onFailed?.call('Failed to show ad. Please try again.');

      _rewardedAd?.dispose();
      _rewardedAd = null;
      _isAdReady = false;

      return false;
    }
  }

  /// Check if ad is ready
  bool get isAdReady => isSupported && adsEnabled && rewardedAdsEnabled && _isAdReady && _rewardedAd != null;

  /// Preload ad (call this early)
  void preloadAd() {
    if (!isSupported || !adsEnabled) return;
    if (!_isAdReady && !_isLoading) {
      loadRewardedAd();
    }
    if (!_isInterstitialReady && !_isInterstitialLoading) {
      loadInterstitialAd();
    }
  }

  /// Load Interstitial Ad
  Future<void> loadInterstitialAd() async {
    if (!isSupported || !adsEnabled || !interstitialAdsEnabled) return;
    
    if (_isInterstitialLoading || _isInterstitialReady) {
      return;
    }

    try {
      _isInterstitialLoading = true;
      debugPrint('🔄 Loading interstitial ad...');

      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('✅ Interstitial ad loaded successfully');
            _interstitialAd = ad;
            _isInterstitialReady = true;
            _isInterstitialLoading = false;

            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialReady = false;
                loadInterstitialAd(); // Load next one
              },
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialReady = false;
                loadInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('❌ Failed to load interstitial ad: ${error.message}');
            _isInterstitialLoading = false;
            _isInterstitialReady = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error loading interstitial ad: $e');
      _isInterstitialLoading = false;
      _isInterstitialReady = false;
    }
  }

  /// Show Interstitial Ad
  Future<bool> showInterstitialAd() async {
    if (!isSupported || !adsEnabled || !interstitialAdsEnabled) return false;

    if (!_isInterstitialReady || _interstitialAd == null) {
      debugPrint('⚠️ Interstitial ad not ready, loading...');
      await loadInterstitialAd();
      return false; 
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('❌ Error showing interstitial ad: $e');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialReady = false;
      loadInterstitialAd();
      return false;
    }
  }

  /// Check if interstitial is ready
  bool get isInterstitialReady => isSupported && adsEnabled && interstitialAdsEnabled && _isInterstitialReady && _interstitialAd != null;

  /// Dispose resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
    _isLoading = false;
    
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialReady = false;
    _isInterstitialLoading = false;
  }

  /// Load App Open Ad
  static Future<void> loadAppOpenAd() async {
    if (!isSupported || !adsEnabled || !appOpenAdsEnabled) return;
    
    if (_isAppOpenLoading || _appOpenAd != null) {
      return;
    }

    try {
      _isAppOpenLoading = true;
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _isAppOpenLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isAppOpenLoading = false;
            _appOpenAd = null;
          },
        ),
      );
    } catch (_) {
      _isAppOpenLoading = false;
      _appOpenAd = null;
    }
  }

  /// Show App Open Ad if available
  static Future<void> showAppOpenAdIfAvailable() async {
    if (!isSupported || !adsEnabled || !appOpenAdsEnabled) return;
    
    if (_isShowingAppOpenAd) {
      return;
    }

    if (_appOpenAd == null) {
      await loadAppOpenAd();
    }

    if (_appOpenAd == null) {
      return;
    }

    final completer = Completer<void>();
    _isShowingAppOpenAd = true;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _appOpenAd = null;
        _isShowingAppOpenAd = false;
        loadAppOpenAd();
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isShowingAppOpenAd = false;
        loadAppOpenAd();
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    _appOpenAd!.show();
    await completer.future;
  }
}
