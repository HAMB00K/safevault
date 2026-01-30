import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/secure_note_model.dart';

abstract class NotesLocalDataSource {
  Future<List<SecureNoteModel>> getAllNotes();
  Future<SecureNoteModel> getNoteById(String id);
  Future<void> addNote(SecureNoteModel note);
  Future<void> updateNote(SecureNoteModel note);
  Future<void> deleteNote(String id);
  Future<List<SecureNoteModel>> searchNotes(String query);
  Future<List<SecureNoteModel>> getFavoriteNotes();
  Future<int> getNoteCount();
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  final DatabaseHelper databaseHelper;

  NotesLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<SecureNoteModel>> getAllNotes() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.secureNotesTable,
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => SecureNoteModel.fromJson(_parseMap(map))).toList();
  }

  @override
  Future<SecureNoteModel> getNoteById(String id) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.secureNotesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      throw Exception('Note not found');
    }
    return SecureNoteModel.fromJson(_parseMap(maps.first));
  }

  @override
  Future<void> addNote(SecureNoteModel note) async {
    final db = await databaseHelper.database;
    await db.insert(
      DatabaseConstants.secureNotesTable,
      _prepareForDb(note.toJson()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateNote(SecureNoteModel note) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseConstants.secureNotesTable,
      _prepareForDb(note.toJson()),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> deleteNote(String id) async {
    final db = await databaseHelper.database;
    await db.delete(
      DatabaseConstants.secureNotesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<SecureNoteModel>> searchNotes(String query) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.secureNotesTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => SecureNoteModel.fromJson(_parseMap(map))).toList();
  }

  @override
  Future<List<SecureNoteModel>> getFavoriteNotes() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseConstants.secureNotesTable,
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => SecureNoteModel.fromJson(_parseMap(map))).toList();
  }

  @override
  Future<int> getNoteCount() async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConstants.secureNotesTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Map<String, dynamic> _prepareForDb(Map<String, dynamic> json) {
    return {
      ...json,
      'tags': jsonEncode(json['tags'] ?? []),
      'isFavorite': json['isFavorite'] == true ? 1 : 0,
    };
  }

  Map<String, dynamic> _parseMap(Map<String, dynamic> map) {
    return {
      ...map,
      'tags': jsonDecode(map['tags'] as String? ?? '[]'),
      'isFavorite': map['isFavorite'] == 1,
    };
  }
}
