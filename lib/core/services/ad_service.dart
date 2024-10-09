import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_helper.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;  // Add this line
  bool _isInterstitialAdReady = false;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialVideoAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('Video Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdReady) {
      print('Video Interstitial ad is not ready yet.');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show video interstitial ad: $error');
        ad.dispose();
        loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
    _isInterstitialAdReady = false;
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRewardedAd(Function onRewarded) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadRewardedAd();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          onRewarded();
        },
      );
      _rewardedAd = null;
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _largeBannerAd?.dispose();
  }

  BannerAd? _largeBannerAd;
  bool _isLargeBannerAdReady = false;

  void loadLargeBannerAd() {
    _largeBannerAd = BannerAd(
      adUnitId: AdHelper.largeBannerAdUnitId,
      request: AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isLargeBannerAdReady = true;
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isLargeBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _largeBannerAd?.load();
  }

  BannerAd? get largeBannerAd => _largeBannerAd;
  bool get isLargeBannerAdReady => _isLargeBannerAdReady;
}