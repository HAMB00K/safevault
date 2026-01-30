import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'service_logo.dart';

enum PasswordCategory {
  social,
  banking,
  email,
  work,
  ecommerce,
  gaming,
  other,
}

class PasswordEntity extends Equatable {
  final String id;
  final String title;
  final String username;
  final String encryptedPassword;
  final PasswordCategory category;
  final String? url;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;
  final DateTime? expiresAt;
  final bool isFavorite;
  final bool isTemporary;
  final DateTime? deleteAt;
  final ServiceLogo serviceLogo;

  const PasswordEntity({
    required this.id,
    required this.title,
    required this.username,
    required this.encryptedPassword,
    required this.category,
    this.url,
    this.notes,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
    this.expiresAt,
    this.isFavorite = false,
    this.isTemporary = false,
    this.deleteAt,
    this.serviceLogo = ServiceLogo.none,
  });

  PasswordEntity copyWith({
    String? id,
    String? title,
    String? username,
    String? encryptedPassword,
    PasswordCategory? category,
    String? url,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    DateTime? expiresAt,
    bool? isFavorite,
    bool? isTemporary,
    DateTime? deleteAt,
    ServiceLogo? serviceLogo,
  }) {
    return PasswordEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      category: category ?? this.category,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isTemporary: isTemporary ?? this.isTemporary,
      deleteAt: deleteAt ?? this.deleteAt,
      serviceLogo: serviceLogo ?? this.serviceLogo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        username,
        encryptedPassword,
        category,
        url,
        notes,
        tags,
        createdAt,
        updatedAt,
        lastAccessedAt,
        expiresAt,
        isFavorite,
        isTemporary,
        deleteAt,
        serviceLogo,
      ];
}

// Extensions utiles
extension PasswordCategoryExtension on PasswordCategory {
  String get displayName {
    switch (this) {
      case PasswordCategory.social:
        return 'Réseaux sociaux';
      case PasswordCategory.banking:
        return 'Banque & Finance';
      case PasswordCategory.email:
        return 'Email';
      case PasswordCategory.work:
        return 'Travail';
      case PasswordCategory.ecommerce:
        return 'E-commerce';
      case PasswordCategory.gaming:
        return 'Jeux & Divertissement';
      case PasswordCategory.other:
        return 'Autres';
    }
  }

  String get emoji {
    switch (this) {
      case PasswordCategory.social:
        return '🌐';
      case PasswordCategory.banking:
        return '🏦';
      case PasswordCategory.email:
        return '✉️';
      case PasswordCategory.work:
        return '💼';
      case PasswordCategory.ecommerce:
        return '🛒';
      case PasswordCategory.gaming:
        return '🎮';
      case PasswordCategory.other:
        return '🔧';
    }
  }

  String get iconPath {
    switch (this) {
      case PasswordCategory.social:
        return 'assets/icons/socialmedia.png';
      case PasswordCategory.banking:
        return 'assets/icons/bank.png';
      case PasswordCategory.email:
        return 'assets/icons/mail.png';
      case PasswordCategory.work:
        return 'assets/icons/work.png';
      case PasswordCategory.ecommerce:
        return 'assets/icons/e-com.png';
      case PasswordCategory.gaming:
        return 'assets/icons/game.png';
      case PasswordCategory.other:
        return 'assets/icons/other.png';
    }
  }

  Color get color {
    switch (this) {
      case PasswordCategory.social:
        return const Color(0xFF4A90E2); // Bleu
      case PasswordCategory.banking:
        return const Color(0xFF51CF66); // Vert
      case PasswordCategory.email:
        return const Color(0xFFE63946); // Rouge
      case PasswordCategory.work:
        return const Color(0xFF9B59B6); // Violet
      case PasswordCategory.ecommerce:
        return const Color(0xFFFF9500); // Orange
      case PasswordCategory.gaming:
        return const Color(0xFFE91E63); // Rose
      case PasswordCategory.other:
        return const Color(0xFF718096); // Gris
    }
  }
}
