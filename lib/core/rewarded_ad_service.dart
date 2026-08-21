import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Owns the single-use lifecycle required by Google rewarded ads.
abstract final class RewardedAdService {
  static RewardedAd? _ad;
  static Future<void>? _loading;

  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String get _adUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static Future<void> initialize() async {
    if (!_supported) return;
    await MobileAds.instance.initialize();
  }

  static Future<void> preload() {
    if (!_supported || _ad != null) return Future.value();
    return _loading ??= _load();
  }

  static Future<void> _load() async {
    final completer = Completer<void>();
    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          completer.complete();
        },
      ),
    );
    await completer.future;
    _loading = null;
  }

  /// Returns true only when Google invokes the earned-reward callback.
  static Future<bool> show() async {
    if (!_supported) return false;
    await preload();
    final ad = _ad;
    if (ad == null) return false;
    _ad = null;
    final completed = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completed.isCompleted) completed.complete(earned);
        unawaited(preload());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        if (!completed.isCompleted) completed.complete(false);
        unawaited(preload());
      },
    );
    ad.show(onUserEarnedReward: (_, _) => earned = true);
    return completed.future;
  }
}
