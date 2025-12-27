import '../app_modules/imports_module.dart';

/// Mixin to handle common AdMob logic across conversion pages
mixin AdHelper<T extends StatefulWidget> on State<T> {
  final AdMobService _admobService = AdMobService();
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  bool _adWatchedForCurrentFile = false;
  String? _lastSelectedFilePath;

  /// Getters for state
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerReady => _isBannerReady;
  bool get adWatchedForCurrentFile => _adWatchedForCurrentFile;

  @override
  void initState() {
    super.initState();
    _admobService.preloadAd();
    loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _admobService.dispose();
    super.dispose();
  }

  /// Load a banner ad for the current page
  void loadBannerAd() {
    if (!AdMobService.adsEnabled || !AdMobService.bannerAdsEnabled) return;
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isBannerReady = false;
          });
        },
      ),
    )..load();
  }

  /// Build the banner ad widget for the bottom navigation bar
  Widget? buildBannerAd() {
    if (_isBannerReady && _bannerAd != null) {
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  /// Reset ad watch status for a new file
  void resetAdStatus(String? filePath) {
    if (_lastSelectedFilePath != filePath) {
      setState(() {
        _adWatchedForCurrentFile = false;
        _lastSelectedFilePath = filePath;
      });
    }
  }

  /// Manually set ad watched status
  void setAdWatched(bool watched) {
    setState(() {
      _adWatchedForCurrentFile = watched;
    });
  }

  /// Show Interstitial Ad before an action (like saving)
  Future<void> showInterstitialAd() async {
    if (_admobService.isInterstitialReady) {
      debugPrint('🎬 Showing Interstitial Ad');
      await _admobService.showInterstitialAd();
    } else {
      debugPrint('⚠️ Interstitial Ad not ready, loading for next time');
      _admobService.loadInterstitialAd();
    }
  }

  /// Show standardized rewarded ad dialog gate
  Future<bool> showRewardedAdGate({required String toolName}) async {
    if (!AdMobService.adsEnabled || !AdMobService.rewardedAdsEnabled || _adWatchedForCurrentFile) return true;

    // If ad is ready, just show the choice dialog
    if (!_admobService.isAdReady) {
      await _admobService.loadRewardedAd();
      await Future.delayed(const Duration(seconds: 1));
    }

    final watchAd = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Conversion Required',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock_outlined, size: 48, color: AppColors.primaryBlue),
            const SizedBox(height: 16),
            Text(
              'To perform this $toolName conversion, please watch a rewarded video ad.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );

    if (watchAd != true) return false;

    // Show a small loading overlay while ad prepares if needed
    if (!_admobService.isAdReady) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }
      int retries = 0;
      while (!_admobService.isAdReady && retries < 3) {
        await Future.delayed(const Duration(milliseconds: 1500));
        retries++;
      }
      if (mounted) Navigator.of(context).pop(); // Close spinner
    }

    bool adCompleted = false;
    final success = await _admobService.showRewardedAd(
      onRewarded: (reward) {
        adCompleted = true;
        setState(() {
          _adWatchedForCurrentFile = true;
        });
      },
      onFailed: (error) {
        // If ad system fails, let them convert as as fallback
        adCompleted = true;
      }
    );

    return success || adCompleted;
  }
}
