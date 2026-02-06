/// Represents a word used in the charades game
class Word {
  final String text;
  final String? hint; // Optional hint for difficult words
  final int difficulty; // 1-3 (1=easy, 2=medium, 3=hard)

  const Word({required this.text, this.hint, this.difficulty = 1});

  /// Creates a Word from JSON
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      text: json['text'] as String,
      hint: json['hint'] as String?,
      difficulty: json['difficulty'] as int? ?? 1,
    );
  }

  /// Converts Word to JSON
  Map<String, dynamic> toJson() {
    return {'text': text, 'hint': hint, 'difficulty': difficulty};
  }

  /// Creates a copy with modified properties
  Word copyWith({String? text, String? hint, int? difficulty}) {
    return Word(
      text: text ?? this.text,
      hint: hint ?? this.hint,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Word &&
        other.text == text &&
        other.hint == hint &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode => Object.hash(text, hint, difficulty);

  @override
  String toString() => 'Word(text: $text, difficulty: $difficulty)';
}
