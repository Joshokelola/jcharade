import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class GameHelpers {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  /// Plays sound effects for game actions
  static Future<void> playSound({required SoundType type}) async {
    try {
      String soundPath = '';
      switch (type) {
        case SoundType.correct:
          soundPath = 'sounds/correct.mp3';
          break;
        case SoundType.skip:
          soundPath = 'sounds/skip.mp3';
          break;
        case SoundType.gameStart:
          soundPath = 'sounds/game_start.mp3';
          break;
        case SoundType.gameEnd:
          soundPath = 'sounds/game_end.mp3';
          break;
        case SoundType.tick:
          soundPath = 'sounds/tick.mp3';
          break;
      }

      if (soundPath.isNotEmpty) {
        await _audioPlayer.play(AssetSource(soundPath));
      }
    } catch (e) {
      debugPrint('Sound playback error: $e');
    }
  }

  /// Formats time in MM:SS format
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Generates a random list of words from a category
  static List<String> shuffleWords(List<String> words, {int? count}) {
    final shuffled = List<String>.from(words)..shuffle();
    return count != null ? shuffled.take(count).toList() : shuffled;
  }

  /// Calculates the progress percentage
  static double calculateProgress(int current, int total) {
    if (total == 0) return 0.0;
    return (current / total).clamp(0.0, 1.0);
  }

  /// Shows a customized snackbar
  static void showGameSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Generates a Nigerian-themed color gradient
  static LinearGradient getNigerianGradient({bool reverse = false}) {
    const colors = [
      Color(0xFF008751), // Nigerian Green
      Color(0xFF40A578), // Lighter green
      Color(0xFFFFD700), // Gold
    ];

    return LinearGradient(
      colors: reverse ? colors.reversed.toList() : colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

enum SoundType { correct, skip, gameStart, gameEnd, tick }
