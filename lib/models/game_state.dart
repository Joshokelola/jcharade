import 'category.dart';
import 'word.dart';

/// Represents the current state of a charades game
class GameState {
  final Category selectedCategory;
  final List<Word> gameWords;
  final int currentWordIndex;
  final int timerDuration; // in seconds
  final int timeRemaining; // in seconds
  final List<Word> correctWords;
  final List<Word> skippedWords;
  final bool isGameActive;
  final bool isPaused;
  final DateTime? startTime;
  final DateTime? endTime;

  const GameState({
    required this.selectedCategory,
    required this.gameWords,
    this.currentWordIndex = 0,
    required this.timerDuration,
    required this.timeRemaining,
    this.correctWords = const [],
    this.skippedWords = const [],
    this.isGameActive = false,
    this.isPaused = false,
    this.startTime,
    this.endTime,
  });

  /// Creates initial game state
  factory GameState.initial({
    required Category category,
    required int timerDuration,
    int wordsCount = 20,
  }) {
    final gameWords = category.getRandomWords(count: wordsCount);
    return GameState(
      selectedCategory: category,
      gameWords: gameWords,
      timerDuration: timerDuration,
      timeRemaining: timerDuration,
    );
  }

  /// Creates GameState from JSON
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      selectedCategory: Category.fromJson(
        json['selectedCategory'] as Map<String, dynamic>,
      ),
      gameWords: (json['gameWords'] as List<dynamic>)
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
      currentWordIndex: json['currentWordIndex'] as int? ?? 0,
      timerDuration: json['timerDuration'] as int,
      timeRemaining: json['timeRemaining'] as int,
      correctWords: (json['correctWords'] as List<dynamic>? ?? [])
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
      skippedWords: (json['skippedWords'] as List<dynamic>? ?? [])
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
      isGameActive: json['isGameActive'] as bool? ?? false,
      isPaused: json['isPaused'] as bool? ?? false,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
    );
  }

  /// Converts GameState to JSON
  Map<String, dynamic> toJson() {
    return {
      'selectedCategory': selectedCategory.toJson(),
      'gameWords': gameWords.map((w) => w.toJson()).toList(),
      'currentWordIndex': currentWordIndex,
      'timerDuration': timerDuration,
      'timeRemaining': timeRemaining,
      'correctWords': correctWords.map((w) => w.toJson()).toList(),
      'skippedWords': skippedWords.map((w) => w.toJson()).toList(),
      'isGameActive': isGameActive,
      'isPaused': isPaused,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  /// Creates a copy with modified properties
  GameState copyWith({
    Category? selectedCategory,
    List<Word>? gameWords,
    int? currentWordIndex,
    int? timerDuration,
    int? timeRemaining,
    List<Word>? correctWords,
    List<Word>? skippedWords,
    bool? isGameActive,
    bool? isPaused,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return GameState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      gameWords: gameWords ?? this.gameWords,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      timerDuration: timerDuration ?? this.timerDuration,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      correctWords: correctWords ?? this.correctWords,
      skippedWords: skippedWords ?? this.skippedWords,
      isGameActive: isGameActive ?? this.isGameActive,
      isPaused: isPaused ?? this.isPaused,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  /// Gets the current word being played
  Word? get currentWord {
    if (currentWordIndex >= 0 && currentWordIndex < gameWords.length) {
      return gameWords[currentWordIndex];
    }
    return null;
  }

  /// Gets the total number of words completed (correct + skipped)
  int get completedWords => correctWords.length + skippedWords.length;

  /// Gets the game progress as a percentage (0.0 - 1.0)
  double get progress {
    if (gameWords.isEmpty) return 0.0;
    return completedWords / gameWords.length;
  }

  /// Checks if the game is finished
  bool get isGameFinished {
    return currentWordIndex >= gameWords.length || timeRemaining <= 0;
  }

  /// Gets the total score (correct words count)
  int get score => correctWords.length;

  /// Gets the accuracy percentage
  double get accuracy {
    if (completedWords == 0) return 0.0;
    return correctWords.length / completedWords;
  }

  /// Gets the total game duration in seconds
  int? get totalGameDuration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!).inSeconds;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        other.selectedCategory == selectedCategory &&
        other.currentWordIndex == currentWordIndex &&
        other.timeRemaining == timeRemaining &&
        other.isGameActive == isGameActive;
  }

  @override
  int get hashCode => Object.hash(
    selectedCategory,
    currentWordIndex,
    timeRemaining,
    isGameActive,
  );

  @override
  String toString() =>
      'GameState(category: ${selectedCategory.name}, '
      'word: ${currentWordIndex + 1}/${gameWords.length}, '
      'time: ${timeRemaining}s, active: $isGameActive)';
}
