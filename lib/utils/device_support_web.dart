import 'dart:html' as html;

bool isMobileWebUserAgent() {
  final navigator = html.window.navigator;
  final ua = navigator.userAgent.toLowerCase();
  const keywords = ['iphone', 'ipad', 'android', 'mobile', 'tablet', 'safari'];
  final hasTouch = (navigator.maxTouchPoints ?? 0) > 0;
  return hasTouch || keywords.any((keyword) => ua.contains(keyword));
}
