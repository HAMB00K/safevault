import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Erreurs générales
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Erreur serveur']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Erreur de cache']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Erreur réseau']) : super(message);
}

// Erreurs de sécurité
class EncryptionFailure extends Failure {
  const EncryptionFailure([String message = 'Erreur de chiffrement']) : super(message);
}

class DecryptionFailure extends Failure {
  const DecryptionFailure([String message = 'Erreur de déchiffrement']) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Authentification échouée']) : super(message);
}

class BiometricFailure extends Failure {
  const BiometricFailure([String message = 'Biométrie non disponible']) : super(message);
}

// Erreurs de validation
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Données invalides']) : super(message);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([String message = 'Mot de passe trop faible']) : super(message);
}

// Erreurs de stockage
class DatabaseFailure extends Failure {
  const DatabaseFailure([String message = 'Erreur base de données']) : super(message);
}

class StorageFailure extends Failure {
  const StorageFailure([String message = 'Erreur de stockage']) : super(message);
}

// Erreurs métier
class PasswordNotFoundFailure extends Failure {
  const PasswordNotFoundFailure([String message = 'Mot de passe introuvable']) : super(message);
}

class DuplicateEntryFailure extends Failure {
  const DuplicateEntryFailure([String message = 'Entrée déjà existante']) : super(message);
}
