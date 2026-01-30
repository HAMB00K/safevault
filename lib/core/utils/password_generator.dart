import 'dart:math';

class PasswordGenerator {
  static const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String digits = '0123456789';
  static const String symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const String ambiguous = 'il1Lo0O';

  // Génération d'un mot de passe sécurisé
  static String generate({
    required int length,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool includeDigits = true,
    bool includeSymbols = true,
    bool excludeAmbiguous = false,
  }) {
    if (length < 4) {
      throw ArgumentError('Password length must be at least 4');
    }

    String charset = '';
    final List<String> requiredChars = [];

    if (includeLowercase) {
      charset += lowercase;
      requiredChars.add(_getRandomChar(lowercase, excludeAmbiguous));
    }
    if (includeUppercase) {
      charset += uppercase;
      requiredChars.add(_getRandomChar(uppercase, excludeAmbiguous));
    }
    if (includeDigits) {
      charset += digits;
      requiredChars.add(_getRandomChar(digits, excludeAmbiguous));
    }
    if (includeSymbols) {
      charset += symbols;
      requiredChars.add(_getRandomChar(symbols, false));
    }

    if (charset.isEmpty) {
      throw ArgumentError('At least one character set must be selected');
    }

    // Exclure les caractères ambigus si demandé
    if (excludeAmbiguous) {
      for (final char in ambiguous.split('')) {
        charset = charset.replaceAll(char, '');
      }
    }

    final random = Random.secure();
    final password = List<String>.from(requiredChars);

    // Remplir le reste avec des caractères aléatoires
    for (int i = requiredChars.length; i < length; i++) {
      final index = random.nextInt(charset.length);
      password.add(charset[index]);
    }

    // Mélanger le mot de passe
    password.shuffle(random);

    return password.join();
  }

  // Génération d'un caractère aléatoire d'un charset
  static String _getRandomChar(String charset, bool excludeAmbiguous) {
    String validChars = charset;
    if (excludeAmbiguous) {
      for (final char in ambiguous.split('')) {
        validChars = validChars.replaceAll(char, '');
      }
    }
    final random = Random.secure();
    final index = random.nextInt(validChars.length);
    return validChars[index];
  }

  // Génération d'une passphrase (mots aléatoires)
  static String generatePassphrase({
    required int wordCount,
    String separator = '-',
  }) {
    final words = [
      'alpha', 'bravo', 'charlie', 'delta', 'echo', 'foxtrot',
      'golf', 'hotel', 'india', 'juliet', 'kilo', 'lima',
      'mike', 'november', 'oscar', 'papa', 'quebec', 'romeo',
      'sierra', 'tango', 'uniform', 'victor', 'whiskey', 'xray',
      'yankee', 'zulu', 'secure', 'vault', 'cipher', 'guard',
    ];

    final random = Random.secure();
    final selectedWords = <String>[];

    for (int i = 0; i < wordCount; i++) {
      final index = random.nextInt(words.length);
      selectedWords.add(words[index]);
    }

    return selectedWords.join(separator);
  }
}
