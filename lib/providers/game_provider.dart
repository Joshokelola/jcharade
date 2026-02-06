import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/category.dart';
import '../data/predefined_categories.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Provider for managing game state
final gameProvider = NotifierProvider<GameNotifier, GameState?>(() {
  return GameNotifier();
});

/// Notifier for managing game logic and state
class GameNotifier extends Notifier<GameState?> {
  final _storageService = StorageService.instance;

  @override
  GameState? build() {
    _loadSavedGame();
    return null;
  }

  Future<void> _loadSavedGame() async {
    try {
      await _storageService.init();
      final savedGame = await _storageService.loadGameState();
      if (savedGame != null) {
        state = savedGame;
      }
    } catch (e) {
      // If loading fails, start with null state
      state = null;
    }
  }

  /// Initialize a new game with the selected category and timer duration
  Future<void> initializeGame({
    required String categoryId,
    required int timerDuration,
    int wordsCount = 20,
  }) async {
    try {
      await _storageService.init();

      // Get the category
      Category? category;

      // First try predefined categories
      category = PredefinedCategories.getCategoryById(categoryId);

      // If not found, try custom categories
      if (category == null) {
        final customCategories = await _storageService.loadCustomCategories();
        try {
          category = customCategories.firstWhere((cat) => cat.id == categoryId);
        } catch (e) {
          throw Exception('Category not found: $categoryId');
        }
      }

      // Create initial game state
      final gameState = GameState.initial(
        category: category,
        timerDuration: timerDuration,
        wordsCount: wordsCount,
      );

      state = gameState;
      await _saveGameState();
    } catch (e) {
      throw Exception('Failed to initialize game: $e');
    }
  }

  /// Start the game
  void startGame() {
    if (state == null) return;

    state = state!.copyWith(isGameActive: true, startTime: DateTime.now());
    _saveGameState();
  }

  /// Pause the game
  void pauseGame() {
    if (state == null || !state!.isGameActive) return;

    state = state!.copyWith(isPaused: true, isGameActive: false);
    _saveGameState();
  }

  /// Resume the game
  void resumeGame() {
    if (state == null || !state!.isPaused) return;

    state = state!.copyWith(isPaused: false, isGameActive: true);
    _saveGameState();
  }

  /// Mark current word as correct and move to next
  void markWordCorrect() {
    if (state == null || state!.currentWord == null) return;

    final currentWord = state!.currentWord!;
    final updatedCorrectWords = [...state!.correctWords, currentWord];
    final newIndex = state!.currentWordIndex + 1;

    state = state!.copyWith(
      correctWords: updatedCorrectWords,
      currentWordIndex: newIndex,
    );

    _checkGameCompletion();
    _saveGameState();
  }

  /// Skip current word and move to next
  void skipWord() {
    if (state == null || state!.currentWord == null) return;

    final currentWord = state!.currentWord!;
    final updatedSkippedWords = [...state!.skippedWords, currentWord];
    final newIndex = state!.currentWordIndex + 1;

    state = state!.copyWith(
      skippedWords: updatedSkippedWords,
      currentWordIndex: newIndex,
    );

    _checkGameCompletion();
    _saveGameState();
  }

  /// Update the timer
  void updateTimer(int timeRemaining) {
    if (state == null) return;

    state = state!.copyWith(timeRemaining: timeRemaining);

    if (timeRemaining <= 0) {
      endGame();
    } else {
      _saveGameState();
    }
  }

  /// End the game
  void endGame() {
    if (state == null) return;

    state = state!.copyWith(
      isGameActive: false,
      isPaused: false,
      endTime: DateTime.now(),
    );

    _recordGameCompletion();
    _saveGameState();
  }

  /// Reset the game state
  void resetGame() {
    state = null;
    _storageService.clearGameState();
  }

  /// Check if game is completed (all words done or time up)
  void _checkGameCompletion() {
    if (state == null) return;

    if (state!.isGameFinished) {
      endGame();
    }
  }

  /// Save current game state to storage
  Future<void> _saveGameState() async {
    if (state != null) {
      await _storageService.saveGameState(state!);
    }
  }

  /// Record game completion in statistics
  Future<void> _recordGameCompletion() async {
    if (state == null) return;

    try {
      await _storageService.recordGameCompletion(
        categoryId: state!.selectedCategory.id,
        score: state!.score,
        totalWords: state!.gameWords.length,
        duration: state!.totalGameDuration ?? 0,
        completedAt: state!.endTime ?? DateTime.now(),
      );
    } catch (e) {
      // Log error but don't throw - game completion recording shouldn't fail the game
      print('Failed to record game completion: $e');
    }
  }

  /// Get game statistics
  Future<Map<String, dynamic>> getGameStats() async {
    try {
      await _storageService.init();
      return await _storageService.loadGameStats();
    } catch (e) {
      return {};
    }
  }

  /// Check if there's a saved game that can be resumed
  Future<bool> hasSavedGame() async {
    try {
      await _storageService.init();
      final savedGame = await _storageService.loadGameState();
      return savedGame != null && savedGame.isGameActive;
    } catch (e) {
      return false;
    }
  }
}
