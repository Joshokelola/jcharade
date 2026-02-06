import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

/// Service for handling local storage operations
class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  // Singleton pattern
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ============ CUSTOM CATEGORIES ============

  /// Save custom categories to local storage
  Future<bool> saveCustomCategories(List<Category> categories) async {
    try {
      final jsonList = categories.map((category) => category.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(
        AppConstants.customCategoriesKey,
        jsonString,
      );
    } catch (e) {
      print('Error saving custom categories: $e');
      return false;
    }
  }

  /// Load custom categories from local storage
  Future<List<Category>> loadCustomCategories() async {
    try {
      final jsonString = prefs.getString(AppConstants.customCategoriesKey);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading custom categories: $e');
      return [];
    }
  }

  /// Add a new custom category
  Future<bool> addCustomCategory(Category category) async {
    try {
      final categories = await loadCustomCategories();
      categories.add(category);
      return await saveCustomCategories(categories);
    } catch (e) {
      print('Error adding custom category: $e');
      return false;
    }
  }

  /// Update an existing custom category
  Future<bool> updateCustomCategory(Category updatedCategory) async {
    try {
      final categories = await loadCustomCategories();
      final index = categories.indexWhere(
        (cat) => cat.id == updatedCategory.id,
      );

      if (index != -1) {
        categories[index] = updatedCategory;
        return await saveCustomCategories(categories);
      }
      return false;
    } catch (e) {
      print('Error updating custom category: $e');
      return false;
    }
  }

  /// Delete a custom category
  Future<bool> deleteCustomCategory(String categoryId) async {
    try {
      final categories = await loadCustomCategories();
      categories.removeWhere((cat) => cat.id == categoryId);
      return await saveCustomCategories(categories);
    } catch (e) {
      print('Error deleting custom category: $e');
      return false;
    }
  }

  // ============ GAME STATE ============

  /// Save the current game state
  Future<bool> saveGameState(GameState gameState) async {
    try {
      final jsonString = jsonEncode(gameState.toJson());
      return await prefs.setString('current_game_state', jsonString);
    } catch (e) {
      print('Error saving game state: $e');
      return false;
    }
  }

  /// Load the saved game state
  Future<GameState?> loadGameState() async {
    try {
      final jsonString = prefs.getString('current_game_state');
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(json);
    } catch (e) {
      print('Error loading game state: $e');
      return null;
    }
  }

  /// Clear the saved game state
  Future<bool> clearGameState() async {
    try {
      return await prefs.remove('current_game_state');
    } catch (e) {
      print('Error clearing game state: $e');
      return false;
    }
  }

  // ============ GAME STATISTICS ============

  /// Save game statistics
  Future<bool> saveGameStats(Map<String, dynamic> stats) async {
    try {
      final existingStats = await loadGameStats();
      existingStats.addAll(stats);

      final jsonString = jsonEncode(existingStats);
      return await prefs.setString(AppConstants.gameStatsKey, jsonString);
    } catch (e) {
      print('Error saving game stats: $e');
      return false;
    }
  }

  /// Load game statistics
  Future<Map<String, dynamic>> loadGameStats() async {
    try {
      final jsonString = prefs.getString(AppConstants.gameStatsKey);
      if (jsonString == null) return {};

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading game stats: $e');
      return {};
    }
  }

  /// Record a completed game
  Future<bool> recordGameCompletion({
    required String categoryId,
    required int score,
    required int totalWords,
    required int duration,
    required DateTime completedAt,
  }) async {
    try {
      final stats = await loadGameStats();

      // Initialize stats structure if it doesn't exist
      if (!stats.containsKey('games_played')) {
        stats['games_played'] = 0;
        stats['total_score'] = 0;
        stats['total_words'] = 0;
        stats['total_time'] = 0;
        stats['category_stats'] = <String, dynamic>{};
        stats['best_score'] = 0;
        stats['games_history'] = <Map<String, dynamic>>[];
      }

      // Update general stats
      stats['games_played'] = (stats['games_played'] as int) + 1;
      stats['total_score'] = (stats['total_score'] as int) + score;
      stats['total_words'] = (stats['total_words'] as int) + totalWords;
      stats['total_time'] = (stats['total_time'] as int) + duration;

      if (score > (stats['best_score'] as int)) {
        stats['best_score'] = score;
      }

      // Update category-specific stats
      final categoryStats = stats['category_stats'] as Map<String, dynamic>;
      if (!categoryStats.containsKey(categoryId)) {
        categoryStats[categoryId] = {
          'games_played': 0,
          'total_score': 0,
          'best_score': 0,
        };
      }

      final catStat = categoryStats[categoryId] as Map<String, dynamic>;
      catStat['games_played'] = (catStat['games_played'] as int) + 1;
      catStat['total_score'] = (catStat['total_score'] as int) + score;

      if (score > (catStat['best_score'] as int)) {
        catStat['best_score'] = score;
      }

      // Add to games history (keep only last 10 games)
      final history = stats['games_history'] as List<dynamic>;
      history.insert(0, {
        'category_id': categoryId,
        'score': score,
        'total_words': totalWords,
        'duration': duration,
        'completed_at': completedAt.toIso8601String(),
      });

      if (history.length > 10) {
        history.removeRange(10, history.length);
      }

      return await saveGameStats(stats);
    } catch (e) {
      print('Error recording game completion: $e');
      return false;
    }
  }

  // ============ APP SETTINGS ============

  /// Save app settings
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      return await prefs.setString(AppConstants.settingsKey, jsonString);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  /// Load app settings
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final jsonString = prefs.getString(AppConstants.settingsKey);
      if (jsonString == null) {
        return {
          'sound_enabled': true,
          'vibration_enabled': true,
          'default_timer': AppConstants.defaultTimerDuration,
          'auto_next_word': true,
        };
      }

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading settings: $e');
      return {
        'sound_enabled': true,
        'vibration_enabled': true,
        'default_timer': AppConstants.defaultTimerDuration,
        'auto_next_word': true,
      };
    }
  }

  /// Update a specific setting
  Future<bool> updateSetting(String key, dynamic value) async {
    try {
      final settings = await loadSettings();
      settings[key] = value;
      return await saveSettings(settings);
    } catch (e) {
      print('Error updating setting: $e');
      return false;
    }
  }

  // ============ UTILITY METHODS ============

  /// Clear all stored data (for debugging or reset)
  Future<bool> clearAllData() async {
    try {
      await prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  /// Get storage size information
  Future<Map<String, int>> getStorageInfo() async {
    try {
      final customCategoriesSize =
          prefs.getString(AppConstants.customCategoriesKey)?.length ?? 0;
      final gameStatsSize =
          prefs.getString(AppConstants.gameStatsKey)?.length ?? 0;
      final settingsSize =
          prefs.getString(AppConstants.settingsKey)?.length ?? 0;

      return {
        'custom_categories': customCategoriesSize,
        'game_stats': gameStatsSize,
        'settings': settingsSize,
        'total': customCategoriesSize + gameStatsSize + settingsSize,
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {};
    }
  }
}
