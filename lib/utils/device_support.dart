import 'package:flutter/foundation.dart';

import 'device_support_stub.dart'
    if (dart.library.html) 'device_support_web.dart';

class DeviceSupport {
  static bool get isMobileOrTablet {
    if (kIsWeb) {
      return isMobileWebUserAgent();
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }
}
