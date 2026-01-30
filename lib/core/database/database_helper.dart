import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    // Créer la base de données avec chiffrement
    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      password: await _getDatabasePassword(),
    );
  }

  Future<String> _getDatabasePassword() async {
    // TODO: Récupérer depuis le secure storage ou dériver du master password
    // Pour l'instant, utiliser un mot de passe par défaut (à sécuriser)
    return 'safevault_default_db_password_2024';
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table des mots de passe
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.passwordsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        username TEXT NOT NULL,
        encryptedPassword TEXT NOT NULL,
        category TEXT NOT NULL,
        url TEXT,
        notes TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        lastAccessedAt TEXT,
        expiresAt TEXT,
        isFavorite INTEGER DEFAULT 0,
        isTemporary INTEGER DEFAULT 0,
        deleteAt TEXT,
        serviceLogo TEXT DEFAULT 'none'
      )
    ''');

    // Table des notes sécurisées
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.secureNotesTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        encryptedContent TEXT NOT NULL,
        category TEXT,
        tags TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0
      )
    ''');

    // Table des documents chiffrés
    await db.execute('''
      CREATE TABLE secure_documents (
        id TEXT PRIMARY KEY,
        fileName TEXT NOT NULL,
        encryptedData TEXT NOT NULL,
        fileType TEXT,
        fileSize INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Table des utilisateurs (pour multi-user)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        masterPasswordHash TEXT NOT NULL,
        salt TEXT NOT NULL,
        biometricEnabled INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT
      )
    ''');

    // Table des journaux d'activité
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.activityLogsTable} (
        id TEXT PRIMARY KEY,
        userId TEXT,
        action TEXT NOT NULL,
        entityType TEXT,
        entityId TEXT,
        timestamp TEXT NOT NULL,
        details TEXT
      )
    ''');

    // Index pour optimiser les recherches
    await db.execute('''
      CREATE INDEX idx_passwords_category ON ${DatabaseConstants.passwordsTable}(category)
    ''');
    await db.execute('''
      CREATE INDEX idx_passwords_favorite ON ${DatabaseConstants.passwordsTable}(isFavorite)
    ''');
    await db.execute('''
      CREATE INDEX idx_passwords_temporary ON ${DatabaseConstants.passwordsTable}(isTemporary)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajouter la colonne serviceLogo
      await db.execute('''
        ALTER TABLE ${DatabaseConstants.passwordsTable} ADD COLUMN serviceLogo TEXT DEFAULT 'none'
      ''');
    }
  }

  // Méthodes utilitaires pour les transactions
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Fermer la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Supprimer la base de données (pour reset complet)
  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);
    
    if (await File(path).exists()) {
      await File(path).delete();
    }
    
    _database = null;
  }

  // Vérifier la santé de la DB
  Future<bool> isHealthy() async {
    try {
      final db = await database;
      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      return false;
    }
  }
}
