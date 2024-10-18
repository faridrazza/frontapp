import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9842922624465296/1652552159';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9842922624465296/1678099747";  // Replace with your actual ad unit ID
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";  // Replace with your actual ad unit ID
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialVideoAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-9842922624465296/5241940233"; // Test video interstitial ad unit ID for Android
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/5135589807"; // Test video interstitial ad unit ID for iOS
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get largeBannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9842922624465296/1652552159'; // Replace with your actual ad unit ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Replace with your actual ad unit ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}