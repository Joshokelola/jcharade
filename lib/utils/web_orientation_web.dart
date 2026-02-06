import 'dart:html' as html;

Future<void> lockLandscape() async {
  try {
    await html.window.screen?.orientation?.lock('landscape');
  } catch (_) {
    // Some browsers require explicit user gesture; ignore errors.
  }
}

Future<void> unlockOrientation() async {
  try {
    html.window.screen?.orientation?.unlock();
  } catch (_) {
    // Ignore when unsupported.
  }
}
