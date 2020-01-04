import 'package:admob_flutter/admob_flutter.dart';

String getAppId() {
  return 'ca-app-pub-5105356979867269~5826498364';
}

String getBannerAdUnitId() {
  return 'ca-app-pub-5105356979867269/9575484765';
}

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        print('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        print('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        print('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        print('Admob $adType failed to load. :(');
        break;
      default:
    }
  }
