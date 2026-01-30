import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/vault/presentation/providers/vault_provider.dart';

/// Service pour gérer les mots de passe temporaires avec auto-suppression
class TemporaryVaultService {
  Timer? _cleanupTimer;
  final Ref _ref;

  TemporaryVaultService(this._ref) {
    _startCleanupTimer();
  }

  /// Démarrer le timer de nettoyage (toutes les minutes)
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _cleanupExpiredPasswords(),
    );
  }

  /// Nettoyer les mots de passe temporaires expirés
  Future<void> _cleanupExpiredPasswords() async {
    try {
      await _ref.read(passwordsProvider.notifier).deleteExpiredTemporaryPasswords();
    } catch (e) {
      // Ignorer les erreurs silencieusement
      print('TemporaryVaultService: Erreur lors du nettoyage: $e');
    }
  }

  /// Arrêter le service
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }

  /// Forcer le nettoyage
  Future<void> forceCleanup() async {
    await _cleanupExpiredPasswords();
  }
}

/// Options de durée pour les mots de passe temporaires
enum TemporaryDuration {
  oneHour,
  sixHours,
  oneDay,
  threeDays,
  oneWeek,
  oneMonth,
}

extension TemporaryDurationExtension on TemporaryDuration {
  String get displayName {
    switch (this) {
      case TemporaryDuration.oneHour:
        return '1 heure';
      case TemporaryDuration.sixHours:
        return '6 heures';
      case TemporaryDuration.oneDay:
        return '1 jour';
      case TemporaryDuration.threeDays:
        return '3 jours';
      case TemporaryDuration.oneWeek:
        return '1 semaine';
      case TemporaryDuration.oneMonth:
        return '1 mois';
    }
  }

  Duration get duration {
    switch (this) {
      case TemporaryDuration.oneHour:
        return const Duration(hours: 1);
      case TemporaryDuration.sixHours:
        return const Duration(hours: 6);
      case TemporaryDuration.oneDay:
        return const Duration(days: 1);
      case TemporaryDuration.threeDays:
        return const Duration(days: 3);
      case TemporaryDuration.oneWeek:
        return const Duration(days: 7);
      case TemporaryDuration.oneMonth:
        return const Duration(days: 30);
    }
  }

  DateTime get deleteAt => DateTime.now().add(duration);
}

/// Provider pour le service de coffre-fort temporaire
final temporaryVaultServiceProvider = Provider<TemporaryVaultService>((ref) {
  final service = TemporaryVaultService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
