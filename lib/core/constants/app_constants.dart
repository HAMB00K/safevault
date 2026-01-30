// Constantes de sécurité
class SecurityConstants {
  static const int pbkdf2Iterations = 100000;
  static const int aesKeyLength = 256;
  static const int saltLength = 32;
  static const int autoLockTimeoutSeconds = 120; // 2 minutes
  static const int maxLoginAttempts = 5;
  static const int loginTimeoutSeconds = 300; // 5 minutes
  static const int clipboardClearSeconds = 30;
  static const int minPasswordLength = 12;
}

// Constantes de l'application
class AppConstants {
  static const String appName = 'SafeVault';
  static const String appVersion = '1.0.0';
  static const int paginationLimit = 50;
  static const int maxPasswordHistoryCount = 5;
}

// Clés de stockage
class StorageKeys {
  static const String masterPasswordHash = 'master_password_hash';
  static const String masterPasswordSalt = 'master_password_salt';
  static const String encryptionKey = 'encryption_key';
  static const String biometricEnabled = 'biometric_enabled';
  static const String autoLockTimeout = 'auto_lock_timeout';
  static const String themeMode = 'theme_mode';
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastActivityTimestamp = 'last_activity_timestamp';
}

// Noms de tables de la base de données
class DatabaseConstants {
  static const String databaseName = 'safevault.db';
  static const int databaseVersion = 2;
  
  // Tables
  static const String passwordsTable = 'passwords';
  static const String categoriesTable = 'categories';
  static const String activityLogsTable = 'activity_logs';
  static const String secureNotesTable = 'secure_notes';
}
