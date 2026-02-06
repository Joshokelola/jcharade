

import 'package:web/web.dart' as html;

Future<void> requestMotionPermission() async {
  try {
    html.window.navigator.permissions.query(
      {'name': 'accelerometer'} as dynamic,
    );
  } catch (e) {
    // If permissions API isn't available, fall back silently.
    // Some browsers require user gestures handled elsewhere.
  }
}
