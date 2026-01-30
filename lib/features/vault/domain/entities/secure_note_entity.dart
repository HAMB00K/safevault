import 'package:equatable/equatable.dart';

enum NoteCategory {
  personal,
  work,
  finance,
  health,
  travel,
  other,
}

class SecureNoteEntity extends Equatable {
  final String id;
  final String title;
  final String encryptedContent;
  final NoteCategory category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  const SecureNoteEntity({
    required this.id,
    required this.title,
    required this.encryptedContent,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  SecureNoteEntity copyWith({
    String? id,
    String? title,
    String? encryptedContent,
    NoteCategory? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return SecureNoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        encryptedContent,
        category,
        tags,
        createdAt,
        updatedAt,
        isFavorite,
      ];
}

// Extension pour les catégories de notes
extension NoteCategoryExtension on NoteCategory {
  String get displayName {
    switch (this) {
      case NoteCategory.personal:
        return 'Personnel';
      case NoteCategory.work:
        return 'Travail';
      case NoteCategory.finance:
        return 'Finance';
      case NoteCategory.health:
        return 'Santé';
      case NoteCategory.travel:
        return 'Voyage';
      case NoteCategory.other:
        return 'Autre';
    }
  }

  String get emoji {
    switch (this) {
      case NoteCategory.personal:
        return '👤';
      case NoteCategory.work:
        return '💼';
      case NoteCategory.finance:
        return '💰';
      case NoteCategory.health:
        return '🏥';
      case NoteCategory.travel:
        return '✈️';
      case NoteCategory.other:
        return '📝';
    }
  }

  int get colorValue {
    switch (this) {
      case NoteCategory.personal:
        return 0xFF7C183C;
      case NoteCategory.work:
        return 0xFF1E88E5;
      case NoteCategory.finance:
        return 0xFF43A047;
      case NoteCategory.health:
        return 0xFFE53935;
      case NoteCategory.travel:
        return 0xFFFB8C00;
      case NoteCategory.other:
        return 0xFF8E24AA;
    }
  }
}
