import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/datasources/vault_local_datasource.dart';
import '../../data/repositories/vault_repository_impl.dart';
import '../../domain/entities/password_entity.dart';
import '../../domain/entities/service_logo.dart';
import '../../domain/repositories/vault_repository.dart';

// State pour gérer les mots de passe
class PasswordsState {
  final List<PasswordEntity> passwords;
  final bool isLoading;
  final String? error;

  const PasswordsState({
    this.passwords = const [],
    this.isLoading = false,
    this.error,
  });

  PasswordsState copyWith({
    List<PasswordEntity>? passwords,
    bool? isLoading,
    String? error,
  }) {
    return PasswordsState(
      passwords: passwords ?? this.passwords,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// StateNotifier pour gérer les mots de passe
class PasswordsNotifier extends StateNotifier<PasswordsState> {
  final VaultRepository repository;
  
  PasswordsNotifier(this.repository) : super(const PasswordsState()) {
    _initialize();
  }

  final _uuid = const Uuid();

  Future<void> _initialize() async {
    await loadPasswords();
  }

  // Charger tous les mots de passe
  Future<void> loadPasswords() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await repository.getAllPasswords();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (passwords) => state = state.copyWith(
        passwords: passwords,
        isLoading: false,
      ),
    );
  }

  // Ajouter un mot de passe
  Future<void> addPassword({
    required String title,
    required String username,
    required String password,
    required PasswordCategory category,
    ServiceLogo serviceLogo = ServiceLogo.none,
    String? url,
    String? notes,
    List<String> tags = const [],
    bool isTemporary = false,
    DateTime? deleteAt,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final newPassword = PasswordEntity(
      id: _uuid.v4(),
      title: title,
      username: username,
      encryptedPassword: password,
      category: category,
      serviceLogo: serviceLogo,
      url: url,
      notes: notes,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isTemporary: isTemporary,
      deleteAt: deleteAt,
    );

    final result = await repository.addPassword(newPassword);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) async {
        await loadPasswords();
      },
    );
  }

  // Mettre à jour un mot de passe
  Future<void> updatePassword(PasswordEntity updatedPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    final passwordToUpdate = updatedPassword.copyWith(
      updatedAt: DateTime.now(),
    );

    final result = await repository.updatePassword(passwordToUpdate);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) async {
        await loadPasswords();
      },
    );
  }

  // Supprimer un mot de passe
  Future<void> deletePassword(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.deletePassword(id);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) async {
        await loadPasswords();
      },
    );
  }

  // Basculer le statut favori d'un mot de passe
  Future<void> toggleFavorite(String id) async {
    final password = state.passwords.firstWhere((p) => p.id == id);
    final updatedPassword = password.copyWith(
      isFavorite: !password.isFavorite,
      updatedAt: DateTime.now(),
    );
    
    // Mettre à jour localement immédiatement pour un feedback instantané
    final updatedList = state.passwords.map((p) {
      return p.id == id ? updatedPassword : p;
    }).toList();
    
    state = state.copyWith(passwords: updatedList);
    
    // Persister dans la base de données
    await repository.updatePassword(updatedPassword);
  }

  // Obtenir les mots de passe favoris
  List<PasswordEntity> getFavoritePasswords() {
    return state.passwords.where((p) => p.isFavorite).toList();
  }

  // Rechercher des mots de passe
  List<PasswordEntity> searchPasswords(String query) {
    if (query.isEmpty) return state.passwords;

    return state.passwords
        .where((pwd) =>
            pwd.title.toLowerCase().contains(query.toLowerCase()) ||
            pwd.username.toLowerCase().contains(query.toLowerCase()) ||
            (pwd.url?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }

  // Obtenir les mots de passe par catégorie
  List<PasswordEntity> getPasswordsByCategory(PasswordCategory category) {
    return state.passwords
        .where((pwd) => pwd.category == category)
        .toList();
  }

  // Obtenir le nombre de mots de passe par catégorie
  int getCategoryCount(PasswordCategory category) {
    return state.passwords
        .where((pwd) => pwd.category == category)
        .length;
  }

  // Supprimer tous les mots de passe
  Future<void> deleteAllPasswords() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      for (final password in state.passwords) {
        await repository.deletePassword(password.id);
      }

      state = state.copyWith(
        passwords: [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Supprimer les mots de passe temporaires expirés
  Future<void> deleteExpiredTemporaryPasswords() async {
    final result = await repository.deleteExpiredTemporaryPasswords();
    result.fold(
      (failure) => null,
      (_) => loadPasswords(),
    );
  }
}

// Providers pour la dépendance injection
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final vaultLocalDataSourceProvider = Provider<VaultLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return VaultLocalDataSourceImpl(databaseHelper);
});

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  final localDataSource = ref.watch(vaultLocalDataSourceProvider);
  return VaultRepositoryImpl(localDataSource);
});

// Provider principal
final passwordsProvider =
    StateNotifierProvider<PasswordsNotifier, PasswordsState>((ref) {
  final repository = ref.watch(vaultRepositoryProvider);
  return PasswordsNotifier(repository);
});
