import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'J-Headsup';
  static const String appVersion = '1.0.0';

  // Timer Durations (in seconds)
  static const List<int> timerDurations = [180, 300, 420];
  static const int defaultTimerDuration = 180;

  // Game Settings
  static const int wordsPerRound = 20;
  static const int maxWordsPerCategory = 25;

  // Nigerian Theme Colors
  static const Color nigerianGreen = Color(0xFF008751);
  static const Color nigerianWhite = Color(0xFFFFFFFF);
  static const Color nigerianGold = Color(0xFFFFD700);

  // Game UI Colors
  static const Color correctGreen = Color(0xFF4CAF50);
  static const Color skipOrange = Color(0xFFFF9800);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceColor = Color(0xFF2D2D2D);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white70,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Tilt Thresholds
  static const double tiltThresholdUp = 0.5; // Phone face up
  static const double tiltThresholdDown = -0.5; // Phone face down

  // Storage Keys
  static const String customCategoriesKey = 'custom_categories';
  static const String gameStatsKey = 'game_statistics';
  static const String settingsKey = 'app_settings';
}
