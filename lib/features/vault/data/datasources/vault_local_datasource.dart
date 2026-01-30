import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/password_model.dart';

abstract class VaultLocalDataSource {
  Future<List<PasswordModel>> getAllPasswords();
  Future<PasswordModel> getPasswordById(String id);
  Future<void> addPassword(PasswordModel password);
  Future<void> updatePassword(PasswordModel password);
  Future<void> deletePassword(String id);
  Future<List<PasswordModel>> searchPasswords(String query);
  Future<List<PasswordModel>> getPasswordsByCategory(String category);
  Future<List<PasswordModel>> getFavoritePasswords();
  Future<List<PasswordModel>> getTemporaryPasswords();
  Future<void> deleteExpiredTemporaryPasswords();
  Future<int> getPasswordCount();
}

class VaultLocalDataSourceImpl implements VaultLocalDataSource {
  final DatabaseHelper databaseHelper;

  VaultLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<PasswordModel>> getAllPasswords() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.passwordsTable,
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => PasswordModel.fromJson(_parseMap(map))).toList();
  }

  @override
  Future<PasswordModel> getPasswordById(String id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.passwordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      throw Exception('Password not found');
    }
    return PasswordModel.fromJson(_parseMap(maps.first));
  }

  @override
  Future<void> addPassword(PasswordModel password) async {
    final db = await databaseHelper.database;
    await db.insert(
      DatabaseConstants.passwordsTable,
      _prepareForDb(password.toJson()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updatePassword(PasswordModel password) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseConstants.passwordsTable,
      _prepareForDb(password.toJson()),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  @override
  Future<void> deletePassword(String id) async {
    final db = await databaseHelper.database;
    await db.delete(
      DatabaseConstants.passwordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<PasswordModel>> searchPasswords(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.passwordsTable,
      where: 'title LIKE ? OR username LIKE ? OR url LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => PasswordModel.fromJson(_parseMap(map))).toList();
  }

  @override
  Future<List<PasswordModel>> getPasswordsByCategory(String category) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.passwordsTable,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => PasswordModel.fromJson(_parseMap(map))).toList();
  }

  @override
  Future<List<PasswordModel>> getFavoritePasswords() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.passwordsTable,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => PasswordModel.fromJson(_parseMap(map))).toList();
  }

  @override
  Future<List<PasswordModel>> getTemporaryPasswords() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.passwordsTable,
      where: 'isTemporary = ?',
      whereArgs: [1],
      orderBy: 'deleteAt ASC',
    );
    return maps.map((map) => PasswordModel.fromJson(_parseMap(map))).toList();
  }

  @override
  Future<void> deleteExpiredTemporaryPasswords() async {
    final db = await databaseHelper.database;
    final now = DateTime.now().toIso8601String();
    await db.delete(
      DatabaseConstants.passwordsTable,
      where: 'isTemporary = ? AND deleteAt <= ?',
      whereArgs: [1, now],
    );
  }

  @override
  Future<int> getPasswordCount() async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.passwordsTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Convertir les listes en JSON pour la DB
  Map<String, dynamic> _prepareForDb(Map<String, dynamic> json) {
    return {
      ...json,
      'tags': jsonEncode(json['tags'] ?? []),
      'isFavorite': json['isFavorite'] == true ? 1 : 0,
      'isTemporary': json['isTemporary'] == true ? 1 : 0,
    };
  }

  // Parser les JSON depuis la DB
  Map<String, dynamic> _parseMap(Map<String, dynamic> map) {
    return {
      ...map,
      'tags': jsonDecode(map['tags'] as String? ?? '[]'),
      'isFavorite': map['isFavorite'] == 1,
      'isTemporary': map['isTemporary'] == 1,
    };
  }
}

