import '../../domain/entities/password_entity.dart';
import '../../domain/entities/service_logo.dart';

class PasswordModel extends PasswordEntity {
  const PasswordModel({
    required super.id,
    required super.title,
    required super.username,
    required super.encryptedPassword,
    required super.category,
    super.url,
    super.notes,
    super.tags,
    required super.createdAt,
    required super.updatedAt,
    super.lastAccessedAt,
    super.expiresAt,
    super.isFavorite,
    super.isTemporary,
    super.deleteAt,
    super.serviceLogo,
  });

  factory PasswordModel.fromJson(Map<String, dynamic> json) {
    return PasswordModel(
      id: json['id'] as String,
      title: json['title'] as String,
      username: json['username'] as String,
      encryptedPassword: json['encryptedPassword'] as String,
      category: PasswordCategory.values.firstWhere(
        (e) => e.toString() == 'PasswordCategory.${json['category']}',
      ),
      url: json['url'] as String?,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isTemporary: json['isTemporary'] as bool? ?? false,
      deleteAt: json['deleteAt'] != null
          ? DateTime.parse(json['deleteAt'] as String)
          : null,
      serviceLogo: json['serviceLogo'] != null
          ? ServiceLogo.values.firstWhere(
              (e) => e.toString() == 'ServiceLogo.${json['serviceLogo']}',
              orElse: () => ServiceLogo.none,
            )
          : ServiceLogo.none,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'encryptedPassword': encryptedPassword,
      'category': category.toString().split('.').last,
      'url': url,
      'notes': notes,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'isTemporary': isTemporary,
      'deleteAt': deleteAt?.toIso8601String(),
      'serviceLogo': serviceLogo.toString().split('.').last,
    };
  }

  factory PasswordModel.fromEntity(PasswordEntity entity) {
    return PasswordModel(
      id: entity.id,
      title: entity.title,
      username: entity.username,
      encryptedPassword: entity.encryptedPassword,
      category: entity.category,
      url: entity.url,
      notes: entity.notes,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastAccessedAt: entity.lastAccessedAt,
      expiresAt: entity.expiresAt,
      isFavorite: entity.isFavorite,
      isTemporary: entity.isTemporary,
      deleteAt: entity.deleteAt,
      serviceLogo: entity.serviceLogo,
    );
  }
}
