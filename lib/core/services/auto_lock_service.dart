import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// État du verrouillage automatique
class AutoLockState {
  final int timeoutSeconds;
  final int remainingSeconds;
  final bool isActive;
  final bool isLocked;

  const AutoLockState({
    this.timeoutSeconds = 300, // 5 minutes par défaut
    this.remainingSeconds = 300,
    this.isActive = false,
    this.isLocked = true,
  });

  AutoLockState copyWith({
    int? timeoutSeconds,
    int? remainingSeconds,
    bool? isActive,
    bool? isLocked,
  }) {
    return AutoLockState(
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isActive: isActive ?? this.isActive,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  String get formattedRemaining {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Notifier pour gérer le verrouillage automatique
class AutoLockNotifier extends StateNotifier<AutoLockState> {
  AutoLockNotifier(this._storage) : super(const AutoLockState()) {
    _loadSettings();
  }

  final FlutterSecureStorage _storage;
  Timer? _timer;
  static const String _timeoutKey = 'auto_lock_timeout';

  /// Charger les paramètres sauvegardés
  Future<void> _loadSettings() async {
    final savedTimeout = await _storage.read(key: _timeoutKey);
    if (savedTimeout != null) {
      final timeout = int.tryParse(savedTimeout) ?? 300;
      // Ne pas reset remainingSeconds si le timer est déjà actif
      if (!state.isActive) {
        state = state.copyWith(
          timeoutSeconds: timeout,
          remainingSeconds: timeout,
        );
      } else {
        state = state.copyWith(timeoutSeconds: timeout);
      }
    }
  }

  /// Définir le timeout de verrouillage automatique
  Future<void> setAutoLockTimeout(int seconds) async {
    await _storage.write(key: _timeoutKey, value: seconds.toString());
    state = state.copyWith(
      timeoutSeconds: seconds,
      remainingSeconds: seconds,
    );
    if (state.isActive) {
      _restartTimer();
    }
  }

  /// Démarrer le timer de verrouillage (après déverrouillage)
  void startTimer() {
    _timer?.cancel();
    state = state.copyWith(
      isActive: true,
      isLocked: false,
      remainingSeconds: state.timeoutSeconds,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  /// Callback du timer
  void _onTick(Timer timer) {
    if (state.remainingSeconds <= 1) {
      lock();
    } else {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    }
  }

  /// Réinitialiser le timer (activité utilisateur)
  void resetTimer() {
    if (state.isActive && !state.isLocked) {
      state = state.copyWith(remainingSeconds: state.timeoutSeconds);
    }
  }

  /// Redémarrer le timer
  void _restartTimer() {
    _timer?.cancel();
    state = state.copyWith(remainingSeconds: state.timeoutSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  /// Verrouiller manuellement ou automatiquement
  void lock() {
    _timer?.cancel();
    state = state.copyWith(
      isActive: false,
      isLocked: true,
      remainingSeconds: state.timeoutSeconds,
    );
  }

  /// Déverrouiller (appelé après authentification réussie)
  void unlock() {
    state = state.copyWith(isLocked: false);
    startTimer();
  }

  /// Arrêter complètement le timer
  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(isActive: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider pour le secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
});

/// Provider principal pour le verrouillage automatique
final autoLockProvider = StateNotifierProvider<AutoLockNotifier, AutoLockState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AutoLockNotifier(storage);
});
