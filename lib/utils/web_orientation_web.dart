import 'package:web/web.dart' as html;

Future<void> lockLandscape() async {
  try {
    html.document.documentElement?.requestFullscreen();
    html.window.screen.orientation.lock('landscape');
  } catch (_) {
    // Some browsers require explicit user gesture; ignore errors.
  }
}

Future<void> unlockOrientation() async {
  try {
    html.window.screen.orientation.unlock();
  } catch (_) {
    // Ignore when unsupported.
  }
}
