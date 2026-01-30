import '../../domain/entities/secure_note_entity.dart';

class SecureNoteModel extends SecureNoteEntity {
  const SecureNoteModel({
    required super.id,
    required super.title,
    required super.encryptedContent,
    required super.category,
    super.tags,
    required super.createdAt,
    required super.updatedAt,
    super.isFavorite,
  });

  factory SecureNoteModel.fromJson(Map<String, dynamic> json) {
    return SecureNoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      encryptedContent: json['encryptedContent'] as String,
      category: NoteCategory.values.firstWhere(
        (e) => e.toString() == 'NoteCategory.${json['category']}',
        orElse: () => NoteCategory.other,
      ),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'encryptedContent': encryptedContent,
      'category': category.toString().split('.').last,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory SecureNoteModel.fromEntity(SecureNoteEntity entity) {
    return SecureNoteModel(
      id: entity.id,
      title: entity.title,
      encryptedContent: entity.encryptedContent,
      category: entity.category,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isFavorite: entity.isFavorite,
    );
  }
}
