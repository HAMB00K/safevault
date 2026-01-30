import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../features/vault/domain/entities/password_entity.dart';
import '../../features/vault/data/models/password_model.dart';
import 'encryption_service.dart';

enum ExportFormat { json, csv, encrypted }

class ImportExportService {
  /// Exporter les mots de passe en JSON
  static Future<String> exportToJson(List<PasswordEntity> passwords) async {
    final List<Map<String, dynamic>> data = passwords
        .map((p) => PasswordModel.fromEntity(p).toJson())
        .toList();

    final exportData = {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'count': passwords.length,
      'passwords': data,
    };

    return jsonEncode(exportData);
  }

  /// Exporter les mots de passe en CSV
  static String exportToCsv(List<PasswordEntity> passwords) {
    final buffer = StringBuffer();
    
    // En-têtes CSV
    buffer.writeln('title,username,password,category,url,notes,createdAt');

    // Données
    for (final password in passwords) {
      final row = [
        _escapeCsv(password.title),
        _escapeCsv(password.username),
        _escapeCsv(password.encryptedPassword),
        password.category.toString().split('.').last,
        _escapeCsv(password.url ?? ''),
        _escapeCsv(password.notes ?? ''),
        password.createdAt.toIso8601String(),
      ].join(',');
      buffer.writeln(row);
    }

    return buffer.toString();
  }

  /// Exporter avec chiffrement
  static Future<String> exportEncrypted(
    List<PasswordEntity> passwords,
    String masterPassword,
  ) async {
    final jsonData = await exportToJson(passwords);
    // EncryptionService.encrypt gère le salt et IV en interne
    final encrypted = EncryptionService.encrypt(jsonData, masterPassword);

    final exportData = {
      'version': '1.0',
      'encrypted': true,
      'data': encrypted,
    };

    return jsonEncode(exportData);
  }

  /// Importer depuis JSON
  static Future<List<PasswordEntity>> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);

      if (data is Map && data.containsKey('passwords')) {
        // Format SafeVault
        final passwordsList = data['passwords'] as List;
        return passwordsList
            .map((p) => PasswordModel.fromJson(p as Map<String, dynamic>))
            .toList();
      } else if (data is List) {
        // Format simple (liste directe)
        return data
            .map((p) => PasswordModel.fromJson(p as Map<String, dynamic>))
            .toList();
      }

      throw const FormatException('Format JSON non reconnu');
    } catch (e) {
      throw FormatException('Erreur lors de l\'import JSON: $e');
    }
  }

  /// Importer depuis CSV
  static List<PasswordEntity> importFromCsv(String csvContent) {
    final lines = csvContent.split('\n').where((l) => l.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      throw const FormatException('Fichier CSV vide');
    }

    // Ignorer l'en-tête
    final dataLines = lines.skip(1);
    final passwords = <PasswordEntity>[];

    for (final line in dataLines) {
      final values = _parseCsvLine(line);
      
      if (values.length >= 3) {
        final password = PasswordModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: values[0],
          username: values[1],
          encryptedPassword: values[2],
          category: _parseCategory(values.length > 3 ? values[3] : 'other'),
          url: values.length > 4 ? values[4] : null,
          notes: values.length > 5 ? values[5] : null,
          createdAt: values.length > 6
              ? DateTime.tryParse(values[6]) ?? DateTime.now()
              : DateTime.now(),
          updatedAt: DateTime.now(),
        );
        passwords.add(password);
      }
    }

    return passwords;
  }

  /// Importer depuis fichier chiffré
  static Future<List<PasswordEntity>> importEncrypted(
    String encryptedContent,
    String masterPassword,
  ) async {
    try {
      final data = jsonDecode(encryptedContent);

      if (data['encrypted'] != true) {
        throw const FormatException('Ce fichier n\'est pas chiffré');
      }

      final encryptedData = data['data'] as String;

      // EncryptionService.decrypt extrait le salt et IV automatiquement
      final decrypted = EncryptionService.decrypt(
        encryptedData,
        masterPassword,
      );

      return importFromJson(decrypted);
    } catch (e) {
      throw FormatException('Erreur lors du déchiffrement: $e');
    }
  }

  /// Sauvegarder et partager un fichier d'export
  static Future<void> saveAndShare(
    String content,
    String fileName,
  ) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Export SafeVault',
    );
  }

  /// Sélectionner et lire un fichier
  static Future<String?> pickAndReadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv', 'svault'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      return await file.readAsString();
    }

    return null;
  }

  /// Déterminer le format d'un fichier importé
  static ExportFormat detectFormat(String content) {
    try {
      final data = jsonDecode(content);
      if (data is Map && data['encrypted'] == true) {
        return ExportFormat.encrypted;
      }
      return ExportFormat.json;
    } catch (_) {
      // Si ce n'est pas du JSON, c'est du CSV
      return ExportFormat.csv;
    }
  }

  // Helpers privés

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }

    result.add(current.toString());
    return result;
  }

  static PasswordCategory _parseCategory(String category) {
    try {
      return PasswordCategory.values.firstWhere(
        (c) => c.toString().split('.').last.toLowerCase() == category.toLowerCase(),
        orElse: () => PasswordCategory.other,
      );
    } catch (_) {
      return PasswordCategory.other;
    }
  }
}
