import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../core/utils/biometric_helper.dart';

// State pour l'authentification
class AuthState {
  final bool isAuthenticated;
  final bool hasMasterPassword;
  final bool biometricEnabled;
  final bool biometricAvailable;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.hasMasterPassword = false,
    this.biometricEnabled = false,
    this.biometricAvailable = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? hasMasterPassword,
    bool? biometricEnabled,
    bool? biometricAvailable,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasMasterPassword: hasMasterPassword ?? this.hasMasterPassword,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// StateNotifier pour l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._storage) : super(const AuthState(isLoading: true)) {
    _checkMasterPassword();
  }

  final FlutterSecureStorage _storage;
  static const String _masterPasswordKey = 'master_password_hash';
  static const String _biometricEnabledKey = 'biometric_enabled';
  bool _initialized = false;

  /// Vérifie si l'initialisation est terminée
  bool get isInitialized => _initialized;

  /// Attendre que l'initialisation soit terminée
  Future<void> waitForInitialization() async {
    // Attendre jusqu'à ce que _initialized soit true
    while (!_initialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // Vérifier si un master password existe
  Future<void> _checkMasterPassword() async {
    try {
      final hash = await _storage.read(key: _masterPasswordKey);
      final biometricEnabled = await _storage.read(key: _biometricEnabledKey);
      final biometricAvailable = await BiometricHelper.isBiometricAvailable();
      
      state = state.copyWith(
        hasMasterPassword: hash != null,
        biometricEnabled: biometricEnabled == 'true',
        biometricAvailable: biometricAvailable,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        hasMasterPassword: false,
        isLoading: false,
      );
    } finally {
      _initialized = true;
    }
  }

  // Hacher le mot de passe
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Créer le master password
  Future<bool> createMasterPassword(String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final hash = _hashPassword(password);
      await _storage.write(key: _masterPasswordKey, value: hash);
      
      state = state.copyWith(
        hasMasterPassword: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la création du master password',
      );
      return false;
    }
  }

  // Vérifier le master password
  Future<bool> verifyMasterPassword(String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final storedHash = await _storage.read(key: _masterPasswordKey);
      
      if (storedHash == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Aucun master password configuré',
        );
        return false;
      }

      final inputHash = _hashPassword(password);
      final isValid = inputHash == storedHash;

      state = state.copyWith(
        isAuthenticated: isValid,
        isLoading: false,
        error: isValid ? null : 'Mot de passe incorrect',
      );

      return isValid;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la vérification',
      );
      return false;
    }
  }

  // Activer la biométrie
  Future<bool> enableBiometric() async {
    if (!state.biometricAvailable) {
      state = state.copyWith(error: 'Biométrie non disponible sur cet appareil');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authenticated = await BiometricHelper.authenticate(
        localizedReason: 'Activez la biométrie pour SafeVault',
      );

      if (authenticated) {
        await _storage.write(key: _biometricEnabledKey, value: 'true');
        state = state.copyWith(
          biometricEnabled: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Authentification biométrique échouée',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'activation de la biométrie',
      );
      return false;
    }
  }

  // Désactiver la biométrie
  Future<void> disableBiometric() async {
    await _storage.delete(key: _biometricEnabledKey);
    state = state.copyWith(biometricEnabled: false);
  }

  // Authentifier avec la biométrie
  Future<bool> authenticateWithBiometric() async {
    if (!state.biometricEnabled || !state.biometricAvailable) {
      state = state.copyWith(error: 'Biométrie non disponible');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authenticated = await BiometricHelper.authenticate(
        localizedReason: 'Authentifiez-vous pour accéder à SafeVault',
      );

      state = state.copyWith(
        isAuthenticated: authenticated,
        isLoading: false,
        error: authenticated ? null : 'Authentification biométrique échouée',
      );

      return authenticated;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de l\'authentification biométrique',
      );
      return false;
    }
  }

  // Vérifier la disponibilité de la biométrie
  Future<void> checkBiometricAvailability() async {
    final isAvailable = await BiometricHelper.isBiometricAvailable();
    state = state.copyWith(biometricAvailable: isAvailable);
  }

  // Déconnexion
  void logout() {
    state = state.copyWith(isAuthenticated: false);
  }

  // Réinitialiser l'erreur
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider pour le secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
});

// Provider principal pour l'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});