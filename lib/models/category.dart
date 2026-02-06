import 'word.dart';

/// Represents a category of words for the charades game
class Category {
  final String id;
  final String name;
  final String description;
  final String icon; // Icon name or emoji
  final List<Word> words;
  final bool isCustom; // True for user-created categories
  final DateTime? createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.words,
    this.isCustom = false,
    this.createdAt,
  });

  /// Creates a Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      words: (json['words'] as List<dynamic>)
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList(),
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Converts Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'words': words.map((w) => w.toJson()).toList(),
      'isCustom': isCustom,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy with modified properties
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    List<Word>? words,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      words: words ?? this.words,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Gets the number of words in this category
  int get wordCount => words.length;

  /// Gets words filtered by difficulty
  List<Word> getWordsByDifficulty(int difficulty) {
    return words.where((word) => word.difficulty == difficulty).toList();
  }

  /// Gets a random subset of words
  List<Word> getRandomWords({int? count}) {
    final shuffledWords = List<Word>.from(words)..shuffle();
    return count != null ? shuffledWords.take(count).toList() : shuffledWords;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name, words: ${words.length})';
}
