import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import '../constants/app_constants.dart';

class EncryptionService {
  // Génération d'un salt aléatoire cryptographiquement sécurisé
  static Uint8List generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(SecurityConstants.saltLength);
    for (int i = 0; i < SecurityConstants.saltLength; i++) {
      salt[i] = random.nextInt(256);
    }
    return salt;
  }

  // Dérivation de clé avec PBKDF2
  static Uint8List deriveKey(String password, Uint8List salt) {
    final bytes = utf8.encode(password);
    final hmac = Hmac(sha256, salt);
    
    var result = hmac.convert(bytes).bytes;
    for (int i = 1; i < SecurityConstants.pbkdf2Iterations; i++) {
      result = hmac.convert(result).bytes;
    }
    
    return Uint8List.fromList(result);
  }

  // Hash du master password avec salt
  static String hashMasterPassword(String password, Uint8List salt) {
    final derived = deriveKey(password, salt);
    return base64Encode(derived);
  }

  // Vérification du master password
  static bool verifyMasterPassword(
    String password,
    String storedHash,
    Uint8List salt,
  ) {
    final hash = hashMasterPassword(password, salt);
    return hash == storedHash;
  }

  // Chiffrement AES-256-GCM
  static String encrypt(String plainText, String password) {
    try {
      final salt = generateSalt();
      final key = deriveKey(password, salt);
      
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(
          encrypt_lib.Key(key),
          mode: encrypt_lib.AESMode.gcm,
        ),
      );
      
      final iv = encrypt_lib.IV.fromSecureRandom(16);
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      // Format: salt + iv + encrypted
      final combined = <int>[]
        ..addAll(salt)
        ..addAll(iv.bytes)
        ..addAll(encrypted.bytes);
      
      return base64Encode(combined);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Déchiffrement AES-256-GCM
  static String decrypt(String encryptedData, String password) {
    try {
      final combined = base64Decode(encryptedData);
      
      // Extraction: salt + iv + encrypted
      final salt = Uint8List.fromList(
        combined.sublist(0, SecurityConstants.saltLength),
      );
      final iv = Uint8List.fromList(
        combined.sublist(
          SecurityConstants.saltLength,
          SecurityConstants.saltLength + 16,
        ),
      );
      final encrypted = Uint8List.fromList(
        combined.sublist(SecurityConstants.saltLength + 16),
      );
      
      final key = deriveKey(password, salt);
      
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(
          encrypt_lib.Key(key),
          mode: encrypt_lib.AESMode.gcm,
        ),
      );
      
      final decrypted = encrypter.decrypt(
        encrypt_lib.Encrypted(encrypted),
        iv: encrypt_lib.IV(iv),
      );
      
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Effacement sécurisé d'une variable sensible
  static void secureWipe(List<int> data) {
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
}
